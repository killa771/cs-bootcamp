namespace: Integrations.demo.aos.tools
flow:
  name: initilize_artifact
  inputs:
    - host: 10.0.46.44
    - username: "${get_sp('vm_username')}"
    - password: "${get_sp('vm_password')}"
    - artifact_url:
        required: false
    - script_url: 'http://vmdocker.hcm.demo.local:36980/job/AOS-repo/ws/install_tomcat.sh'
    - parameters:
        required: false
  workflow:
    - is_atrifact_given:
        do:
          io.cloudslang.base.strings.string_equals:
            - first_string: '${artifact_url}'
        navigate:
          - SUCCESS: copy_script
          - FAILURE: copy_artifact
    - copy_script:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - url: '${script_url}'
        publish:
          - script_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: ssh_command
    - copy_artifact:
        do:
          Integrations.demo.aos.sub_flows.remote_copy:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - url: '${artifact_url}'
        publish:
          - artifact_name: '${filename}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: copy_script
    - ssh_command:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: "${'cd '+get_sp('script_location')+' && chmod 755 '+script_name+' && sh '+script_name+' '+get('artifact_name', '')+' '+get('parameters', '')+' > '+script_name+'.log'}"
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
        publish:
          - command_return_code
        navigate:
          - SUCCESS: delete_script
          - FAILURE: delete_script
    - delete_script:
        do:
          Integrations.demo.aos.tools.delete_file:
            - host: '${host}'
            - username: '${username}'
            - password: '${password}'
            - filename: '${script_name}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: is_true
    - is_true:
        do:
          io.cloudslang.base.utils.is_true:
            - bool_value: "${str(command_return_code == '0')}"
        navigate:
          - 'TRUE': SUCCESS
          - 'FALSE': FAILURE
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      is_atrifact_given:
        x: 308
        y: 30
      copy_script:
        x: 418
        y: 184
      copy_artifact:
        x: 92
        y: 195
      ssh_command:
        x: 104
        y: 342
      delete_script:
        x: 326.66668701171875
        y: 343.8095397949219
      is_true:
        x: 551
        y: 328
        navigate:
          61d4fae7-523f-6400-f152-c056eec6a120:
            targetId: 8b880f5b-35dd-6b07-979c-82fd89a1a6c3
            port: 'TRUE'
          dba2f652-9f48-e87c-846f-60eb00b49220:
            targetId: c8c46153-b205-e798-36c0-4943b230e3e8
            port: 'FALSE'
    results:
      SUCCESS:
        8b880f5b-35dd-6b07-979c-82fd89a1a6c3:
          x: 676.1904907226562
          y: 230.4761962890625
      FAILURE:
        c8c46153-b205-e798-36c0-4943b230e3e8:
          x: 681.90478515625
          y: 422.857177734375
