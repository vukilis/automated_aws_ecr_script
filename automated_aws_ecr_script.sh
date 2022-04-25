#!/bin/bash

clear

echo -ne "\e[1;32m
----------------------------------------------------------------------------
----------------------       SCRIPT STARTED      ---------------------------
----------------------------------------------------------------------------
"
echo -ne "\e[1;31m
----------------------------------------------------------------------------
        !!! YOUR DOCKER IMAGE MUST BE NAMED SAME AS AWS REPOSITORY !!!
----------------------------------------------------------------------------
                        Automated AWS ECR SCRIPT
                            MadeBy: Vuk1lis™
                        https://github.com/vukilis

Script for automated create, push and delete AWS ECR repositories and images.
    Created and optimized for DataDrill Company https://www.datadrill.io/
----------------------------------------------------------------------------
\e[1;33m"



################ DECLARATION ################
AWS_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
ENDPOINT=dkr.ecr.$AWS_REGION.amazonaws.com

# show all available crawlers // need to improve
showCrawlers(){

    echo -e "\e[1;33m"
    echo "
    gazzettaufficiale_biz, fda_gov, ansm_sante_fr, has_sante_fr
    "
    echo -e "\e[1;36m"
}
# push repo image
push(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------------       DOCKER PUSH      --------------------------"
    echo "----------------------------------------------------------------------------"

    sudo docker tag tracking_core_$crawler:latest $AWS_ID.$ENDPOINT/$crawler:latest
    sudo docker push $AWS_ID.$ENDPOINT/$crawler:latest
    echo -e "\e[1;36m"
}
# docker check images
checkImage(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------------       IMAGE CHECK      --------------------------"
    echo "----------------------------------------------------------------------------"

    aws ecr describe-images --repository-name $crawler --image-ids imageTag=latest --output json
    echo -e "\e[1;36m"
}
#create ECR repo
createRepo(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "-----------------------       CREATE REPOSITORY      -----------------------"
    echo "----------------------------------------------------------------------------"

    aws ecr create-repository --repository-name $crawler
    echo -e "\e[1;36m"
}
# delete repo image
deleteImage(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------------       DELETE IMAGE      -------------------------"
    echo "----------------------------------------------------------------------------"

    aws ecr batch-delete-image --repository-name $crawler --image-ids imageTag=latest
    echo -e "\e[1;36m"
}
# delete ECR repo
deleteRepo(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "-----------------------       DELETE REPOSITORY      -----------------------"
    echo "----------------------------------------------------------------------------"
    
    aws ecr delete-repository --repository-name $crawler --force
    echo -e "\e[1;36m"
}

################ AWS LOGIN ################

echo -ne "\e[1;35m
----------------------------------------------------------------------------
---------------------------       AWS LOGIN      ---------------------------
----------------------------------------------------------------------------
\e[1;33m"

# docker login
aws ecr get-login-password --region $AWS_REGION | sudo docker login --username AWS --password-stdin $AWS_ID.$ENDPOINT > /tmp/output.txt
if grep -qi "Login Succeeded" /tmp/output.txt; then
    cat /tmp/output.txt
    rm -f /tmp/output.txt 
else
    echo -e "\e[1;31m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------------       LOGIN ERROR      --------------------------"
    echo "----------------------------------------------------------------------------"
    echo -e "\e[1;36m"
    exit
fi

################ SCRIPT MENU ################

echo -ne "\e[1;35m
----------------------------------------------------------------------------
----------------------------       OPTIONS      ----------------------------
----------------------------------------------------------------------------
\e[1;36m"

PS3="Choose your option: "
options=("check-image" "push-image" "delete-repository-image" "create-repository" "delete-repository" "crawler-list")

select option in "${options[@]}" "Quit"; do 
    case "$REPLY" in
    1) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        read -p "Enter repo name: " crawler 
        checkImage
        continue;;
    2) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        read -p "Enter crawler name: " crawler 
        deleteImage
        push
        continue;;
    3) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        read -p "Enter repo name: " crawler 
        deleteImage
        continue;;
    4) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        read -p "Enter repo name: " crawler 
        createRepo
        continue;;
    5) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        read -p "Enter repo name: " crawler 
        deleteRepo
        continue;;
    6) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        showCrawlers
        echo "Use Ctrl+Shift+C & Ctrl+Shift+V to copy/paste"
        echo ""
        continue;;
    $((${#options[@]}+1))) echo -e "\033[1;31mGoodbye!"; break;;
    *) echo -e "\033[1;31m- $REPLY is invalid option. Try another one. -\033[1;36m";;
    esac
done

# ----------------------------------------------------------------------------
# ------------------------       SCRIPT END      -----------------------------
# ----------------------------------------------------------------------------