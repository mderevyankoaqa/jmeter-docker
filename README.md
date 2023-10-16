# jmeter-docker
The example how to run test in the docker and manage the results 

+ Build image
    ```
    docker build  --build-arg JMETER_VERSION=5.6.2 --build-arg TZ=Europe/Kiev -t "jmeter" .
    ```

+ Rebuild existing image (debugging purposes or some new staff added)
    ```
    docker build  --build-arg JMETER_VERSION=5.6.2 --build-arg TZ=Europe/Kiev --no-cache -t "jmeter" .  
    ```  
+ Run test
    ```
    docker run -it -v /opt/jmeter_automation/results:/opt/test_results jmeter
    ``` 
    The results in the docker will be saved in "/opt/test_results" path. So you can mount that on yor drive; in the example we have "/opt/jmeter_automation/results" folder to see the results from image.