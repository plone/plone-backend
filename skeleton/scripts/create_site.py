from AccessControl.SecurityManagement import newSecurityManager
from pathlib import Path
from plone.distribution.api import site as site_api
from Testing.makerequest import makerequest

import json
import logging
import os
import transaction


logging.basicConfig(format="%(message)s")

# Silence some loggers
for logger_name in [
    "GenericSetup.componentregistry",
    "Products.MimetypesRegistry.MimeTypesRegistry",
]:
    logging.getLogger(logger_name).setLevel(logging.ERROR)

logger = logging.getLogger("Plone Site Creation")
logger.setLevel(logging.DEBUG)

SCRIPT_DIR = Path().cwd() / "scripts"

truthy = frozenset(("t", "true", "y", "yes", "on", "1"))


def asbool(s):
    """Return the boolean value ``True`` if the case-lowered value of string
    input ``s`` is a :term:`truthy string`. If ``s`` is already one of the
    boolean values ``True`` or ``False``, return it."""
    if s is None:
        return False
    if isinstance(s, bool):
        return s
    s = str(s).strip()
    return s.lower() in truthy


app = makerequest(globals()["app"])

request = app.REQUEST

admin = app.acl_users.getUserById("admin")
admin = admin.__of__(app.acl_users)
newSecurityManager(None, admin)

# VARS
ANSWERS = os.getenv("ANSWERS", "default")
DELETE_EXISTING = asbool(os.getenv("DELETE_EXISTING"))
DISTRIBUTION = os.getenv("DISTRIBUTION", "")

if not DISTRIBUTION:
    # We used to support setting TYPE 'volto' or 'classic'.
    TYPE = os.getenv("TYPE", "")
    if TYPE == "classic":
        DISTRIBUTION = "classic"
    elif TYPE == "volto":
        DISTRIBUTION = "volto"

# Load default site creation parameters
answers_file = SCRIPT_DIR / f"{ANSWERS}.json"
answers = json.loads(answers_file.read_text())

# Override the defaults from the OS environment
if DISTRIBUTION:
    answers["distribution"] = DISTRIBUTION
SITE_ID = os.getenv("SITE_ID")
if SITE_ID:
    answers["site_id"] = SITE_ID
LANGUAGE = os.getenv("LANGUAGE")
if LANGUAGE:
    answers["default_language"] = LANGUAGE
SETUP_CONTENT = os.getenv("SETUP_CONTENT")
if SETUP_CONTENT is not None:
    answers["setup_content"] = asbool(SETUP_CONTENT)
TIMEZONE = os.getenv("TIMEZONE")
if TIMEZONE:
    answers["portal_timezone"] = TIMEZONE
ADDITIONAL_PROFILES = os.getenv("PROFILES", os.getenv("ADDITIONAL_PROFILES", ""))
additional_profiles = []
if ADDITIONAL_PROFILES:
    additional_profiles = [profile.strip() for profile in ADDITIONAL_PROFILES.split(",")]

# Get the final site_id and distribution from the updated answers.
site_id = answers["site_id"]
DISTRIBUTION = answers["distribution"]
logger.info(f"Creating a new Plone site  @ {site_id}")
logger.info(f" - Using the {DISTRIBUTION} distribution and answers from {answers_file}")


if site_id in app.objectIds() and DELETE_EXISTING:
    app.manage_delObjects([site_id])
    transaction.commit()
    app._p_jar.sync()
    logger.info(f" - Deleted existing site with id {site_id}")
else:
    logger.info(
        f" - Stopping site creation, as there is already a site with id {site_id}. "
        "Set DELETE_EXISTING=1 to delete the existing site before creating a new one."
    )

if site_id not in app.objectIds():
    site = site_api._create_site(
        context=app, distribution_name=DISTRIBUTION, answers=answers
    )
    transaction.commit()
    app._p_jar.sync()
    logger.info(" - Site created!")

    if additional_profiles:
        for profile_id in additional_profiles:
            logger.info(f" - Importing profile {profile_id}")
            site.portal_setup.runAllImportStepsFromProfile(f"profile-{profile_id}")
        transaction.commit()
        app._p_jar.sync()
