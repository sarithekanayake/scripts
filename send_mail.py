import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import sys 

errlog="/home/ec2-user/scripts/dailybackup/error.log"

fromaddr="ec2scriptnotification@gmail.com"
toaddr="sarithekanayake@gmail.com"
script=sys.argv[1]
respnose=sys.argv[2]
msg = MIMEMultipart()
msg['From'] = fromaddr
msg['To'] = toaddr
msg['Subject'] = "{} script Failed".format(script)

if script=="Web Server":
    body = """{} script is getting {} code response""".format(script,respnose)
elif script=="Daily Backup":
    with open(errlog,'r') as file:
        data = file.read()
    body = """{} script is failed.\nFollowing are the outputs of {} file.\nErrors are on,\n\n{}\nof the dailybackup.sh script""".format(script,respnose,data)

msg.attach(MIMEText(body, 'plain'))

connection = smtplib.SMTP()
connection.connect('email-smtp.ap-southeast-1.amazonaws.com',587)
connection.starttls()
connection.login('AKIAZXI7XNIDH4XUNA56','BKJUpsGvX+Q0RSCoOEo46nWZSTHmoJ+BZ6N0zVykKqQ7')
text = msg.as_string()
connection.sendmail(fromaddr ,toaddr,text)
connection.close()
