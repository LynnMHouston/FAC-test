"""Fixtures to make users that should get sample items."""

import logging

from django.apps import apps
from django.conf import settings
from django.contrib.auth import get_user_model

logger = logging.getLogger(__name__)

# list of users that should be auto-created.
# username here is the UUID for this person's Login.gov user
USERS = [
    {
        "username": settings.TEST_USERNAME,
    },
    {
        "username": "b276a5b3-2d2a-42a3-a078-ad57a36975d4",
        "first_name": "Neil",
        "last_name": "M-B",
    },
]


def load_users():
    """Load default users for testing use."""
    User = get_user_model()
    for item_info in USERS:
        username = item_info["username"]
        if not User.objects.filter(username=username).exists():
            # need to make this user
            logger.info("Creating username %s", username)
            User.objects.create(**item_info)
