import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import sys 

fromaddr="sarithekanayaka@gmail.com"
password = "sarith123"
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
    with open('error.log','r') as file:
        data = file.read()
    body = """{} script is failed.\nFollowing are the outputs of {} file.\nErrors are on,\n\n{}\nof the dailybackup.sh script""".format(script,respnose,data)

msg.attach(MIMEText(body, 'plain'))

connection = smtplib.SMTP('smtp.gmail.com')
connection.starttls()
connection.login(user=fromaddr, password= password)
text = msg.as_string()
connection.sendmail(fromaddr, toaddr, text)
connection.close()