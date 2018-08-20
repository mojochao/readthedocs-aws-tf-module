import os

from .base import CommunityBaseSettings

_DATA_ROOT = '/home/admin/data'


class CommunityLocalSettings(CommunityBaseSettings):

    # Domains and URLs
    PRODUCTION_DOMAIN = '${domain_name}'

    # Sessions
    SESSION_COOKIE_DOMAIN = '${domain_name}'

    # Paths
    DOCROOT = os.path.join(_DATA_ROOT, 'user_builds')
    UPLOAD_ROOT = os.path.join(_DATA_ROOT, 'user_uploads')
    PRODUCTION_ROOT = os.path.join(_DATA_ROOT, 'prod_artifacts')
    PRODUCTION_MEDIA_ARTIFACTS = os.path.join(PRODUCTION_ROOT, 'media')

    @property
    def DATABASES(self):
        return {
            'default': {
                'ENGINE': 'django.db.backends.postgresql_psycopg2',
                'NAME': '${pg_dbname}',
                'USER': '${pg_username}',
                'PASSWORD': '${pg_password}',
                'HOST': '${pg_hostname}',
                'PORT': '',
            }
        }


CommunityLocalSettings.load_settings(__name__)

if not os.environ.get('DJANGO_SETTINGS_SKIP_LOCAL', False):
    try:
        from .local_settings import *  # noqa
    except ImportError:
        pass
