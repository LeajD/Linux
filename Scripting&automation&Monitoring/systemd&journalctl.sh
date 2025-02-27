#you might want to implement such linux service for "jenkins runner" in order to run as agent for Jenkins server on remote EC2 to run as service and gets loaded during booting, monitoring over time etc.
#/usr/lib/systemd/system/jenkins-runner.service
[Unit]
Description=Jenkins Runner Server
Documentation=http://jenkins-ci.org
After=network.target

[Service]
User=jenkins
Group=jenkins
ExecStart=/usr/bin/java -jar /opt/jenkins/agent.jar -jnlpUrl http://<JENKINS_MASTER_URL>/computer/<AGENT_NAME>/slave-agent.jnlp -secret <AGENT_SECRET>
Restart=on-failure
Environment="JENKINS_HOME=/var/lib/jenkins"
WorkingDirectory=/var/lib/jenkins
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target


#simple script to implement reading jenkins-runner service logs and send email alerts in case of errors
#!/bin/bash
journalctl -u jenkins-runner -f | grep -i "error" | while read line
do
    echo "$line" | mail -s "Service Error Alert" your_email@example.com
done



#By default, logs from services managed by systemd are captured and accessible via journalctl but you can specify other logging options in the service file.
#StandardOutput=journal: Ensures that Jenkins logs to the systemd journal (capturing logs).
#StandardOutput=append:/var/log/jenkins/jenkins.log: This will append stdout to the log file. -> make sure to create the log file and give proper permissions to jenkins user.
#StandardError=journal: Ensures that errors are also captured by journalctl.
#StandardError=append:/var/log/jenkins/jenkins.log: This will append stderr to the same log file. -> make sure to create the log file and give proper permissions to jenkins user.
#sudo journalctl -u jenkins -f
