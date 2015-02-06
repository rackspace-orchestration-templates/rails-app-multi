from fabric.api import env, task
from envassert import detect, file, group, port, process, service, user
from hot.utils.test import get_artifacts


@task
def check_app():
    env.platform_family = detect.detect()

    assert file.exists("/home/rails/railsapp/current/config/database.yml"), \
        "database.yml does not exist"
    assert file.exists("/etc/nginx/sites-enabled/railsapp"), \
        "nginx proxy is not configured"
    assert port.is_listening(80), "port 80 is not listening"
    assert user.exists("rails"), "user rails does not exist"
    assert group.is_exists("rails"), "group rails does not exist"
    # envassert uses `ps -A`, which shows `ruby` for the unicorn process name
    assert process.is_up("ruby"), "unicorn process is not up"
    assert service.is_enabled("unicorn"), "unicorn is not enabled"
    assert service.is_enabled("nginx"), \
        "nginx is not enabled"


@task
def check_db_mysql():
    env.platform_family = detect.detect()

    assert file.exists("/etc/mysql/my.cnf"), \
        "/etc/mysql/my.cnf does not exist"
    assert port.is_listening(3306), "port 3306 is not listening"
    assert user.exists("mysql"), "user mysql does not exist"
    assert group.is_exists("mysql"), "group mysql does not exist"
    assert process.is_up("mysqld"), "mysqld process is not up"
    assert service.is_enabled("mysql"), "mysql is not enabled"


@task
def artifacts():
    env.platform_family = detect.detect()
    get_artifacts()
