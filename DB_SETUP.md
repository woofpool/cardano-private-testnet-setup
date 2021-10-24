* Create postgres user having superuser role
  ```bash
    sudo -u postgres createuser --interactive
    # input at prompt
    Enter name of role to add: kurt
    Shall the new role be a superuser? (y/n) y
  ```

* Create postgres connection file