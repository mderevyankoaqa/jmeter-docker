+ The main command to build and run is 

    ```docker compose up```

+ To build using docker 

    ```docker build  --build-arg JMETER_TEST_SCRIPT=init.jmx --build-arg JMETER_TEST_SETTINGS=init.properties -t "jmeter" .```
    
    Notes: src folder has scripts to be executed in the test, so depends tof the test you need, select right *.jmx and *.properties files 

+ To run the the test

    ```docker run -it -v /opt/jmeter_automation/results:/opt/test_results jmeter```


    Annotations: *.properties files has test settings and correspond to the specific jmx file.