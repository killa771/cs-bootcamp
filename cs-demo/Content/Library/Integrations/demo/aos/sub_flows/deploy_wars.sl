namespace: Integrations.demo.aos.sub_flows
flow:
  name: deploy_wars
  inputs:
    - tomcat_host: 10.0.46.44
    - account_service_host: 10.0.46.44
    - db_host: 10.4.46.44
    - username: "${get_sp('vm_username')}"
    - password: "${get_sp('vm_password')}"
    - url: "${get_sp('war_repo_root_url')}"
  workflow:
    - deploy_account_service:
        do:
          Integrations.demo.aos.tools.initilize_artifact:
            - host: '${account_service_host}'
            - username: '${username}'
            - password: '${password}'
            - artifact_url: "${url+'accountservice/target/accountservice.war'}"
            - script_url: "${get_sp('script_deploy_war')}"
            - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: deploy_tm_wars
    - deploy_tm_wars:
        loop:
          for: "war in 'catalog','MasterCredit','order','ROOT','ShipEx','SafePay'"
          do:
            Integrations.demo.aos.tools.initilize_artifact:
              - host: '${tomcat_host}'
              - username: '${username}'
              - password: '${password}'
              - artifact_url: "${url+war.lower()+'/target/'+war+'.war'}"
              - script_url: "${get_sp('script_deploy_war')}"
              - parameters: "${db_host+' postgres admin '+tomcat_host+' '+account_service_host}"
          break:
            - FAILURE
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      deploy_account_service:
        x: 176
        y: 112
      deploy_tm_wars:
        x: 363
        y: 121
        navigate:
          b57ac369-f1d2-74dc-c323-a0e0620cf23c:
            targetId: 5ec64470-d896-784e-07e3-32577cc60628
            port: SUCCESS
    results:
      SUCCESS:
        5ec64470-d896-784e-07e3-32577cc60628:
          x: 598
          y: 115
