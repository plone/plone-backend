# Test Suite

## Running Tests

```console
$ ./run.sh

usage: run.sh [-t test ...] image:tag [...]
   ie: run.sh plone/plone-backend:6.0.0a1
       run.sh -t utc plone/plone-backend:6.0.0a1

This script processes the specified Docker images to test their running
environments.
```

Run all the tests that are applicable to the `plone/plone-backend:6.0.0a1` image:

```console
$ ./run.sh plone/plone-backend:6.0.0a1
testing plone/plone-backend:6.0.0a1
	'utc' [1/4]...passed
	'no-hard-coded-passwords' [2/4]...passed
	'override-cmd' [3/4]...passed
```

## Writing Tests

### `tests/<test name>/`

Each test lives in a separate directory inside `tests/`, and `config.sh` determines which images each test applies to.

#### `tests/<test name>/run.sh`

This is the actual "test script". In the script, `$1` is the name of the image we're testing. An exit code of zero indicates success/passing, and a non-zero exit code indicates failure.

For example, `tests/utc/run.sh` consists of:

```bash
#!/bin/bash
set -e

docker run --rm --entrypoint date "$1" +%Z
```

Which runs `date` inside the given image, and outputs the current timezone according to `date +%Z`, which should be `UTC`. See `tests/<test name>/expected-std-out.txt` below for the other half of this test.

There are several pre-written `run.sh` scripts to help with common tasks. See the `tests/run-*-in-container.sh` section below for more details about these.

#### `tests/<test name>/expected-std-out.txt`

If this file exists, then this test's `run.sh` is expected to output exactly the contents of this file on standard output, and differences will be assumed to denote test failure.

To continue with our `utc` test example, its contents in this file are simply:

	UTC

If a test fails due to having incorrect output, the `diff` between the generated output and the expected output will be displayed:

```console
$ ./run.sh -t utc plone/plone-backend:6.0.0a1
testing plone/plone-backend:6.0.0a1
	'utc' [1/1]...failed; unexpected output:
--- tests/utc/expected-std-out.txt	2015-02-05 16:52:05.013273118 -0700
+++ -	2015-03-13 15:11:49.725116569 -0600
@@ -1 +1 @@
-UTC
+EDT
```

(this is an example of `plone/plone-backend:6.0.0a1` failing the `utc` test)

## Configuring the Test Suite

### `config.sh`

This file controls which tests apply (or don't apply) to each image.

When testing an image, the list of tests to apply are calculated by doing `globalTests + imageTests[testAlias[image]] + imageTests[image]`. Any tests for which `globalExcludeTests[image_test]` is set are removed. If `-t` is specified one or more times, any tests not specified explicitly via `-t` are also removed.

#### `globalTests=( test ... )`

This list of tests applies to every image minus combinations listed in `globalExcludeTests` (such as `hello-world` not getting the `utc` test, since it has no `date` binary in order for the test to work).

```bash
globalTests+=(
	utc
	no-hard-coded-passwords
)
```

#### `testAlias=( [image]='image' ... )`

This array defines image aliases 

#### `imageTests=( [image]='test ...' ... )`

This array defines the list of explicit tests for each image. For example, the `zeo` image has a test which verifies that basic functionality works, such as starting up the image and connecting to it from a separate container.

#### `globalExcludeTests=( [image_test]=1 ... )`

Defines image+test combinations which shouldn't ever run (usually because they won't work, like trying to run `date` in the `hello-world` image for the `utc` test, which has only one binary).

```bash
globalExcludeTests+=(
	# single-binary images
	[hello-world_utc]=1
)
```

### Alternate config files

If you would like to run the Official Image tests against your own images, you can use the `-c/--config` flag to specify one or more alternate config files. These config files should configure the same environment variables used by the default `config.sh` (see above).

```bash
imageTests+=(
	[myorg/myimage]='
		my-custom-test
	'
)
```

**Note**: If you do use your own config file, the `config.sh` included here will no longer be loaded by default. If you want to load it in addition to your own config file (for example, to run the `globalTests` against your own image), use an additional `--config` flag.

```console
$ /path/to/official-images/test/run.sh --config /path/to/official-images/test/config.sh --config ./my-config.sh myimage
```
