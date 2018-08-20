#!/bin/bash
set -x
cd ${readthedocs_root} && ${readthedocs_root}/venv/bin/python3 manage.py migrate
cd ${readthedocs_root} && ${readthedocs_root}/venv/bin/python3 manage.py createsuperuser
cd ${readthedocs_root} && ${readthedocs_root}/venv/bin/python3 manage.py collectstatic
