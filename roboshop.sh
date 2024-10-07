!#/bin/bash
AMI_ID=ami-09c813fb71547fc4f
INSTANCES=("mongodb" "catalogue" "user")
ZONE_ID=Z03707362JEQ4STMRKY6Z
SG_ID=sg-023a93812b480a28d
DOMAIN_NAME="kintravel.shop"

for i in "${INSTANCES[@]}"
do
   if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
     INSTANCE_TYPE="t3.small"
     else
     INSTANCE_TYPE="t2.micro"
   fi

IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications 
"ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
echo "$i: $IP_ADDRESS"
 #create R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
        '
done