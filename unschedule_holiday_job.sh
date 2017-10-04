#!/bin/bash

#=====================================================================================================================================     
#title           :unschedule_holiday_job.sh
#description     :Unschedules the workflows provided into the input file.
#author		 	 :Akshay Pandit
#date            :20170719
#version         :1.2   
#usage		 	 :This script can be executed through Informatica's command task during workflow run itself.
#usage			 :This script can also be invoked through terminal as and when required (preferred way).
#notes           :Edited in sublime text (Windows). Edit using Vim or EMACS in Linux distros.
#bash_version    :GNU bash, version 4.2.46(1)-release (x86_64-redhat-linux-gnu)
#=====================================================================================================================================


unschedule(){
	# -----------------------Create a log for this run---------------------

	tday=`(date +"%m%d%Y")`
	log_dir=/Your/Informatica/Repository/To/Insert/Log/Files
	log_file="$log_dir"`echo $tday"_Unschedule_workflow_Log"`

	# ---------------------------------------------------------------------

	# Check on log file, if it already exists then remove it

	if [ -e $log_file ]; then
		rm -f $log_file
	fi

	echo "Log File = "$log_file
	touch $log_file

	# connect to informatica using service name and domain name
	service="Service_Name_Informatica"
	domain="Domain_Name_Informatica"

		# pick jobs till EOF
		for line in `cat /Your/Informatica/Repository/To/Insert/The/Input/File/To/Be/Read/job_list.txt`
		do
			fldname=`echo $line | cut -d "-" -f 1`
			wfname=`echo $line | cut -d "-" -f 2`

			# get workflow details using pmcmd
			WF_STATUS=`pmcmd getworkflowdetails -sv "$service" -d "$domain" -u $1 -p $2 -f $fldname $wfname | grep "Workflow run type:" | cut -d'[' -f2 | cut -d']' -f1`
			
			# force schedule and then unschedule to remove discrepancies if any.
			WF_Schedule_Status=`pmcmd scheduleworkflow -sv "$service" -d "$domain" -u $1 -p $2 -f $fldname $wfname`
			WF_Unschedule_Status=`pmcmd unscheduleworkflow -sv "$service" -d "$domain" -u $1 -p $2 -f $fldname $wfname | awk '/INFO:/'`
				
			# write the report onto the .txt file
			echo $WF_Unschedule_Status >> '/Your/Informatica/Repository/To/Insert/The/Status/Report/Result/Unschedule_Status_Report.txt'
		done
}

# Send the email to the right stakeholders with report information on unscheduled jobs
sendmail(){
	SENDER="INFA-TEAM<Your.Address@AnyDomain.com>"
	RECEIVER="Receiver.Address@AnyDomain.com,Receiver.Address2@AnyDomain.comm"
	SUBJECT="Bank Holiday unscheduling status Report as on $tday" 
	BODY="Hi Team,\n\nPlease check the attachment for the unscheduled status and status report of the required jobs.\n\nThanks & Regards,\nINFA TEAM" 

	echo -e "$BODY" | mail -s "$SUBJECT" -r "$SENDER" -a "/Your/Informatica/Repository/To/Insert/The/Status/Report/Result/Unschedule_Status_Report.txt" "$RECEIVER"

	# Remove the previously generated status report
	if [ -e "/Your/Informatica/Repository/To/Insert/The/Status/Report/Result/Unschedule_Status_Report.txt" ]; then
		rm -f "/Your/Informatica/Repository/To/Insert/The/Status/Report/Result/Unschedule_Status_Report.txt"
	fi
}

# calling the functions chronologially, $1 and $2 are Informatica username and password respectively.
unschedule $1 $2
sendmail