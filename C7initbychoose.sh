#!/usr/bin/bash
# DESC：system init
# Usage: sh *_init.sh hostname


a () {
# 主机名设置
# 在main函数中以$1传入
        hostnamectl set-hostname $1
        echo "hostname is setting:$(hostname)"
}


b () {
# 关闭firewalld
        systemctl disable firewalld && systemctl stop firewalld

        firewall-cmd --state &> /dev/null

        if [ $? -eq 252 ];then

                echo "firewalld is closed"
        fi
}


c () {
# 关闭SELINUX
        if [ -f /etc/selinux/config ];then

                sed -i.bak -r '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config

        fi

        echo "SELINUX is closed,please restart your system later."

}

d () {
# 清华大学开源软件镜像站YUM源配置
#yum.repos.d backup
mkdir -p /root/yum-back
mv /etc/yum.repos.d/* /root/yum-back/

#make tuna.repo
cat > /etc/yum.repos.d/tuna.repo <<EOF
[base]
name=CentOS-\$releasever - Base
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-\$releasever - Updates
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-\$releasever - Extras
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-\$releasever - Plus
baseurl=http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

EOF

#remove cache
        rm -rf /var/cache/yum &> /dev/null
        yum clean all &> /dev/null

        echo "tsinghuaYUM is added"

}



e () {
# 网络时钟源配置
        if [ -f /etc/ntp.conf ];then
                sed -i.bak -r  '/^server [1-3]/d' /etc/ntp.conf
                sed -i -r '/^server/c\server time1.aliyun.com' /etc/ntp.conf
        fi

        echo "nettime is on"
}

f () {
# 系统更新
        yum update -y

        echo "system update is done"
}

g () {
# 重启系统
        reboot

        
}



main () {

        cat << EOF
==========Linux System INIT==========
        A|a)SET HOSTNAME
        B|b)DISABLE FIREWALLD
        C|c)DISABLE SELINUX
        D|d)SET tsinghuaYUM REPO
        E|e)SET NTP SOURCE
        F|f)UPDTAE SYSTEM
        G|g)REBOOT SYSTEM
=====================================
EOF

read -p "PLEASE CHOOSE NUM TO INIT YOUR SYSTEM[INPUT(q or Q) TO EXIT sh]:"  choice

while true

do

        case $choice in

                A|a)
                        clear
                        a $1
                        sleep 2
                        ;;

                B|b)
                        clear
                        b 
                        sleep 2
                        ;;

                C|c)
                        clear
                        c
                        sleep 2
                        ;;

                D|d)
                        clear
                        d
                        sleep 2
                        ;;

                E|e)
                        clear
                        e
                        sleep 2
                        ;;

                F|f)
                        clear
                        f
                        sleep 2
                        ;;

                G|g)
                        clear
                        g
                        sleep 2
                        ;;
       
                Q|q)
                        echo "EXIT init_sh。"
                        sleep 2
                        break
                        ;;
                *)
                        echo -e "\t\t\t\033[31m choose some num by menu \033[0m"
        esac



cat << EOF
==========Linux System INIT==========
        A|a)SET HOSTNAME
        B|b)DISABLE FIREWALLD
        C|c)DISABLE SELINUX
        D|d)SET tsinghuaYUM REPO
        E|e)SET NTP SOURCE
        F|f)UPDTAE SYSTEM
        G|g)REBOOT SYSTEM
=====================================
EOF

read -p "PLEASE CHOOSE NUM TO INIT YOUR SYSTEM[INPUT(q or Q) TO EXIT sh]:"  choice

done
}

# callable
main $1
