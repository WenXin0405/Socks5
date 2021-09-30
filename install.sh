#!/bin/sh
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Install Basic Tools
yum install git unzip wget -y

#1.清理旧环境和配置新环境
Clear(){
unInstall
clear
echo "旧环境清理完毕！"
echo ""
echo "安装Socks5所依赖的组件,请稍等..."
yum -y install gcc gcc-c++ automake make pam-devel openldap-devel cyrus-sasl-devel openssl-devel
yum update -y nss curl libcurl 

#配置环境变量
sed -i '$a export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' ~/.bash_profile
source ~/.bash_profile

#关闭防火墙
newVersion=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
if [[ ${newVersion} = "7" ]] ; then
 systemctl stop firewalld
 systemctl disable firewalld
 
 elif [[ ${newVersion} = "6" ]] ;then 
 service iptables stop
 chkconfig iptables off
 else
 echo "Exception version"
fi
}

#2.下载Socks5服务
Download()
{
echo ""
echo "下载Socks5服务中..."
cd  /root
git clone https://github.com/wyx176/Socks5
}


#3.安装Socks5服务程序
InstallSock5()
{
echo ""
echo "解压文件中..."
cd  /root/Socks5
tar zxvf ./ss5-3.8.9-8.tar.gz

echo "安装中..."
cd /root/Socks5/ss5-3.8.9
./configure
make
make install
}

#4.安装控制面板配置参数
InstallPanel()
{
#设置默认用户名、默认开启帐号验证
confFile=/etc/opt/ss5/ss5.conf
echo -e Super1 ECYnFg6TqsoUFIO >> /etc/opt/ss5/ss5.passwd
echo -e Super2 ECYnFg6TqsoUFIO >> /etc/opt/ss5/ss5.passwd
sed -i '87c auth    0.0.0.0/0               -               u' $confFile
sed -i '203c permit u	0.0.0.0/0	-	0.0.0.0/0	-	-	-	-	-' $confFile

useradd Super1 -p ECYnFg6TqsoUFIO
useradd Super2 -p ECYnFg6TqsoUFIO

userid1=$(id -u Super1)
userid2=$(id -u Super2)
echo "userid1:"${userid1}
echo "userid2:"${userid2}
ipAdd1="$(curl -s 169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)"
ipAdd2="$(curl -s 169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/address)"
echo "ipAdd1:"${ipAdd1}
echo "ipAdd2:"${ipAdd2}

#添加开机启动
chmod +x /etc/init.d/ss5
# chkconfig --add ss5
# chkconfig --level 345 ss5 on
# confFile=/etc/rc.d/init.d/ss5
# sed -i '/echo -n "Starting ss5... "/a if [ ! -d "/var/run/ss5/" ];then mkdir /var/run/ss5/; fi' $confFile
# sed -i '54c rm -rf /var/run/ss5/' $confFile
# sed -i '18c [[ ${NETWORKING} = "no" ]] && exit 0' $confFile

#判断ss5文件夹是否存在、
if [ ! -d "/var/run/ss5/" ];then
mkdir /var/run/ss5/
echo "create ss5 success!"
else
echo "/ss5/ is OK3333!"
fi
}

#5.检测是否安装完整
check(){
cd /root
rm -rf /root/Socks5
rm -rf /root/install.sh
errorMsg=""
isError=false
if  [ ! -f "/etc/opt/ss5/ss5.conf" ]; then
	errorMsg=${errorMsg}"001|"
	isError=true	
fi

if [ "$isError" = "true" ] ; then
unInstall
clear
  echo ""
  echo "缺失文件，安装失败！！！"
  echo "错误提示："${errorMsg}
  exit 0
else
clear
echo ""
#service ss5 start
if [[ ${newVersion} = "7" ]] ; then
systemctl daemon-reload
fi

# service ss5 start

echo ""
echo "Socks5安装完毕！"
echo ""

echo "默认用户名: Super1 Super2"
echo "默认密码  : ECYnFg6TqsoUFIO"
echo "默认端口  : 55555"
echo ""
echo "添加Telegram群组@Socks55555及时获取更新"
echo ""
exit 0
fi
}

#6.卸载
unInstall(){
service ss5 stop
rm -rf /run/ss5
rm -f 	/run/lock/subsys/ss5
rm -rf /etc/opt/ss5
rm -f /usr/local/bin/s5
rm -rf 	/usr/lib/ss5
rm -f /usr/sbin/ss5
rm -rf /usr/share/doc/ss5
rm -rf /root/ss5-3.8.9
rm -f /etc/sysconfig/ss5
rm -f /etc/rc.d/init.d/ss5
rm -f /etc/pam.d/ss5
rm -rf /var/log/ss5
}

Clear
Download
InstallSock5
InstallPanel
# check
