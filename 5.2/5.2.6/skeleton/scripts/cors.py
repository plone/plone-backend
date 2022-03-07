import os

CORS_TEMPLATE = """<configure
  xmlns="http://namespaces.zope.org/zope">
  <configure
    xmlns="http://namespaces.zope.org/zope"
    xmlns:plone="http://namespaces.plone.org/plone">
    <plone:CORSPolicy
      allow_origin="{allow_origin}"
      allow_methods="{allow_methods}"
      allow_credentials="{allow_credentials}"
      expose_headers="{expose_headers}"
      allow_headers="{allow_headers}"
      max_age="{max_age}"
     />
  </configure>
</configure>
"""

def main(conf="/app/etc/package-includes/999-cors-overrides.zcml"):
    """ Configure CORS Policies
    """
    if not [e for e in os.environ if e.startswith("CORS_")]:
        return

    allow_origin = os.environ.get("CORS_ALLOW_ORIGIN", "http://localhost:3000,http://127.0.0.1:3000")
    allow_methods = os.environ.get("CORS_ALLOW_METHODS", "DELETE,GET,OPTIONS,PATCH,POST,PUT")
    allow_credentials = os.environ.get("CORS_ALLOW_CREDENTIALS", "true")
    expose_headers = os.environ.get("CORS_EXPOSE_HEADERS", "Content-Length,X-My-Header")
    allow_headers = os.environ.get("CORS_ALLOW_HEADERS", "Accept,Authorization,Content-Type,X-Custom-Header,Lock-Token")
    max_age = os.environ.get("CORS_MAX_AGE", "3600")
    cors_conf = CORS_TEMPLATE.format(
        allow_origin=allow_origin,
        allow_methods=allow_methods,
        allow_credentials=allow_credentials,
        expose_headers=expose_headers,
        allow_headers=allow_headers,
        max_age=max_age
    )
    with open(conf, "w") as cors_file:
        cors_file.write(cors_conf)

if __name__ == "__main__":
    main()
