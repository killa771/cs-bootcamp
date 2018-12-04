namespace: Integrations.demo.aos.tools
flow:
  name: delete_file
  inputs:
    - host: 10.0.46.44
    - username: root
    - password: admin@123
    - filename: ShipEx.war
  workflow:
    - delete_file:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && rm -f '+filename}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      delete_file:
        x: 262
        y: 49
        navigate:
          fc22cd8b-5f2d-fe99-9964-472d829cce40:
            targetId: 98d5639a-dc68-8fe0-05ce-5f3220c61964
            port: SUCCESS
    results:
      SUCCESS:
        98d5639a-dc68-8fe0-05ce-5f3220c61964:
          x: 264
          y: 230
