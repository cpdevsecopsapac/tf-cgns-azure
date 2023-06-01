#!/bin/bash


#MY_HOME="/home/ubuntu"
#export DEBIAN_FRONTEND=noninteractive
## Install prereqs
#apt update
#apt install -y python3-pip apt-transport-https ca-certificates curl software-properties-common
## Install docker
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#apt update
#apt install -y docker-ce
## Install docker-compose
#su ubuntu -c "mkdir -p $MY_HOME/.local/bin" 
#su ubuntu -c "pip3 install docker-compose --upgrade --user && chmod 754 $MY_HOME/.local/bin/docker-compose"
#usermod -aG docker ubuntu
## Add PATH
#printf "\nexport PATH=\$PATH:$MY_HOME/.local/bin\n" >> $MY_HOME/.bashrc
#exit 0
#EOF


sudo su -
mv /opt/bitnami/nginx/html/index.html /opt/bitnami/nginx/html/index.html.orig
cat <<EOF > /opt/bitnami/nginx/html/index.html
<HTML>
<HEAD>
<TITLE>Spoke-1</TITLE>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</HEAD>
<BODY BGCOLOR="FFFFFF">
<CENTER><IMG SRC="https://spectralops.io/wp-content/uploads/2022/02/Spectral-Homepage-1.png" alt="サンプル" width="140" height="100" ALIGN="BOTTOM"> </CENTER>
<HR>
<a href="http://somegreatsite.com">リンク名</a>
is a link to another nifty site
<H1>Nginx ウェブサーバ on Spoke-1 vNET</H1>
<H2>これはミディアムヘッダーです</H2>
メールでのお問い合わせはこちら <a href="mailto:support@yourcompany.com">
support@yourcompany.com</a>.
<P> This is a new paragraph!
<P> <B>This is a new paragraph!</B>
<BR> <B><I>This is a new sentence without a paragraph break, in bold italics.</I></B>
<HR>
</BODY>
</HTML>
EOF