#!/bin/bash

#=====================================================================================================================================     
#title           :status_check.sh
#description     :Checks the status of all the workflows in the batch and sends excel sheet about the stats and info onto mail.
#author		 	 :Akshay Pandit
#date            :20170719
#version         :1.2   
#usage		 	 :This script runs automatically through INFA command task, and also mails the excel report to the stakeholders.
#usage			 :This script can also be invoked through terminal as and when required.
#notes           :Edited in sublime text (Windows). Edit using Vim or EMACS in Linux distros.
#bash_version    :GNU bash, version 4.2.46(1)-release (x86_64-redhat-linux-gnu)
#=====================================================================================================================================

#Check status of the workflows anytime 
status_check(){
# -----------------------Create a log for this run---------------------

	tday=`(date +"%m%d%Y")`
	log_dir=Your/Informatica/Repository/To/Insert/Log/Files
	log_file="$log_dir"`echo $tday"_workflow_status_Log"`

# ---------------------------------------------------------------------

	# Remove log file if exists already

	if [ -e $log_file ]; then
		rm -f $log_file
	fi

	echo "Log File = "$log_file
	touch $log_file

	# Connection related credentials initialized, also result file (.csv) created for grasping information.
	service="Provide_Service_Name_Here"
	domain="Provide_Domain_Name_Here"
	STATUS_REPORT=/Your/Informatica/Repository/To/Insert/The/Status/Report/Result`echo $tday"_Status_Report.csv"`
	echo -e "Folder name,Workflow name,Workflow Run status" >> "$STATUS_REPORT" 

	#check current date and run the status on particular workflows only, reads from the .txt files for jobs on particular day
	curr=`date +"%a"`
	if [ $curr = "Mon" ]
	then
		echo "Today is: " $curr
		for line in `cat /Your/Informatica/Repository/To/Insert/The/Input/File/To/Be/Read/Monday_job_list.txt`
			do
				fldname=`echo $line | cut -d "-" -f 1`
				wfname=`echo $line | cut -d "-" -f 2`
	
				WF_STATUS=`pmcmd getworkflowdetails -sv "$service" -d "$domain" -u "$1" -p "$2" -f $fldname $wfname | grep "Workflow run status:" | cut -d'[' -f2 | cut -d']' -f1`	
				echo -e "${fldname},${wfname},$WF_STATUS" >> "$STATUS_REPORT"
			done

	elif [ $curr = "Sun" ]
	then
		echo "Today is: " $curr
		for line in `cat /Your/Informatica/Repository/To/Insert/The/Input/File/To/Be/Read/Sunday_job_list.txt`
			do
				fldname=`echo $line | cut -d "-" -f 1`
				wfname=`echo $line | cut -d "-" -f 2`
	
				WF_STATUS=`pmcmd getworkflowdetails -sv "$service" -d "$domain" -u "$1" -p "$2" -f $fldname $wfname | grep "Workflow run status:" | cut -d'[' -f2 | cut -d']' -f1`	
				echo -e "${fldname},${wfname},$WF_STATUS" >> "$STATUS_REPORT"
			done

	elif [ $curr = "Sat" ]
	then
		echo "Today is: " $curr
		for line in `cat /Your/Informatica/Repository/To/Insert/The/Input/File/To/Be/Read/Saturday_job_list.txt`
			do
				fldname=`echo $line | cut -d "-" -f 1`
				wfname=`echo $line | cut -d "-" -f 2`
	
				WF_STATUS=`pmcmd getworkflowdetails -sv "$service" -d "$domain" -u "$1" -p "$2" -f $fldname $wfname | grep "Workflow run status:" | cut -d'[' -f2 | cut -d']' -f1`	
				echo -e "${fldname},${wfname},$WF_STATUS" >> "$STATUS_REPORT"
			done

	else
		echo "Today is: " $curr
		for line in `cat /Your/Informatica/Repository/To/Insert/The/Input/File/To/Be/Read/Weekday_job_list.txt`
			do
				fldname=`echo $line | cut -d "-" -f 1`
				wfname=`echo $line | cut -d "-" -f 2`
	
				WF_STATUS=`pmcmd getworkflowdetails -sv "$service" -d "$domain" -u "$1" -p "$2" -f $fldname $wfname | grep "Workflow run status:" | cut -d'[' -f2 | cut -d']' -f1`	
				echo -e "${fldname},${wfname},$WF_STATUS" >> "$STATUS_REPORT"
			done
	fi
}

# Send mail to the internal team for reference with the status information in the excel (.csv) attachment
sendmail(){
	
	SENDER="INFA-TEAM<Your.Address@AnyDomain.com>"
	RECEIVER="Receiver.Address@AnyDomain.com"
	SUBJECT="Workflow run status check as on $tday" 
	BODY="Hi Team,\n\nPlease check the attachment for the workflow run status of the jobs.\n\nThanks & Regards,\nYour Name"

	echo -e "$BODY" | mail -s "$SUBJECT" -r "$SENDER" -a "$STATUS_REPORT" "$RECEIVER"

#
# Next fresh start
	if [ -e "$STATUS_REPORT" ]; then
		rm -f "$STATUS_REPORT"
	fi
}

#call the functions chronologically, $1 and $2 are username and password for Informatica connectivity respectively.
status_check $1 $2
sendmail