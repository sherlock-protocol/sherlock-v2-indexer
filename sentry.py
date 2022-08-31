import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

import settings

sentry_sdk.init(
    dsn=settings.SENTRY_DSN,
    environment=settings.SENTRY_ENVIRONMENT,
    integrations=[
        FlaskIntegration(),
    ],
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=0.01,
    # By default the SDK will try to use the SENTRY_RELEASE
    # environment variable, or infer a git commit
    # SHA as release, however you may want to set
    # something more human-readable.
    # release="myapp@1.0.0",
)


def report_message(message: str, level: str = None, extra={}):
    """Capture a message and send it to Sentry

    Available levels are:
        - fatal
        - critical
        - error
        - warning
        - log
        - info
        - debug

    Args:
        message (str): Message text
        extra (dict): Dict of extra items to send with the message
    """

    with sentry_sdk.push_scope() as scope:
        for key, value in extra.items():
            scope.set_extra(key, value)

        sentry_sdk.capture_message(message, level)
