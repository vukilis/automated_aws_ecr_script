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

Automated script for create, push and delete AWS ECR repositories and images.
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
    gazzettaufficiale_biz, fda_gov, ansm_sante_fr, has_sante_fr_decision_opinions, has_sante_fr_drug_decisions
    "
    echo -e "\e[1;36m"
}
# push repo image
push(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------------       DOCKER PUSH      --------------------------"
    echo "----------------------------------------------------------------------------"

    sudo docker tag tracking_core_$input:latest $AWS_ID.$ENDPOINT/$input:latest
    sudo docker push $AWS_ID.$ENDPOINT/$input:latest
    echo -e "\e[1;36m"
}
# docker check images
checkImage(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------------       IMAGE CHECK      --------------------------"
    echo "----------------------------------------------------------------------------"

    aws ecr describe-images --repository-name $input --image-ids imageTag=latest --output json
    echo -e "\e[1;36m"
}
#create ECR repo
createRepo(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "-----------------------       CREATE REPOSITORY      -----------------------"
    echo "----------------------------------------------------------------------------"

    aws ecr create-repository --repository-name $input
    echo -e "\e[1;36m"
}
# delete repo image
deleteImage(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------------       DELETE IMAGE      -------------------------"
    echo "----------------------------------------------------------------------------"

    aws ecr batch-delete-image --repository-name $input --image-ids imageTag=latest
    echo -e "\e[1;36m"
}
# delete ECR repo
deleteRepo(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "-----------------------       DELETE REPOSITORY      -----------------------"
    echo "----------------------------------------------------------------------------"
    
    aws ecr delete-repository --repository-name $input --force
    echo -e "\e[1;36m"
}
#build docker-compose
buildCompose(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "-------------------------      BUILD COMPOSE     ---------------------------"
    echo "----------------------------------------------------------------------------"

    sudo docker-compose -f $composeName build
    echo -e "\e[1;36m"
}
#build docker-compose with args
buildComposeArgs(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "--------------------      BUILD COMPOSE WITH ARGS     ----------------------"
    echo "----------------------------------------------------------------------------"

    sudo docker-compose -f $composeName build $args
    echo -e "\e[1;36m"
}
# delete local docker image
deleteLocalImage(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "----------------------      DELETE LOCAL IMAGE     -------------------------"
    echo "----------------------------------------------------------------------------"

    localID=$(sudo docker images -q $AWS_ID.$ENDPOINT/$input)
    sudo docker rmi -f $localID
    echo -e "\e[1;36m"
}
#delete docker cache
deleteDockerCache(){
    echo -e "\e[1;35m"
    echo "----------------------------------------------------------------------------"
    echo "----------------------      DELETE DOCKER CACHE     ------------------------"
    echo "----------------------------------------------------------------------------"

    sudo docker system prune --all
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
---------------------------       MAIN MENU      ---------------------------
----------------------------------------------------------------------------
\e[1;36m"

PS3="Choose your option: "
menu=("AWS OPTIONS" "DOCKER OPTIONS")
subMenuAWS=("check-image" "push-image" "delete-repository-image" "create-repository" "delete-repository" "crawler-list")
subMenuDOCKER=("build-compose" "build-compose-with-args" "delete-local-image" "delete-docker-cache")

select option in "${menu[@]}" "Quit"; do 
    case "$REPLY" in
    1) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        select optionAWS in "${subMenuAWS[@]}" "Back"; do 
            case "$REPLY" in
            1) echo -e "\033[1;32mYou chose $optionAWS\n\033[1;36m" 
                read -p "Enter repo name: " input 
                checkImage
                REPLY=
                continue;;
            2) echo -e "\033[1;32mYou chose $optionAWS\n\033[1;36m" 
                read -p "Enter crawler name: " input 
                deleteImage
                push
                REPLY=
                continue;;
            3) echo -e "\033[1;32mYou chose $optionAWS\n\033[1;36m" 
                read -p "Enter repo name: " input 
                deleteImage
                REPLY=
                continue;;
            4) echo -e "\033[1;32mYou chose $optionAWS\n\033[1;36m" 
                read -p "Enter repo name: " input 
                createRepo
                REPLY=
                continue;;
            5) echo -e "\033[1;32mYou chose $optionAWS\n\033[1;36m" 
                read -p "Enter repo name: " input 
                deleteRepo
                REPLY=
                continue;;
            6) echo -e "\033[1;32mYou chose $optionAWS\n\033[1;36m" 
                showCrawlers
                echo "Use Ctrl+Shift+C & Ctrl+Shift+V to copy/paste"
                echo ""
                REPLY=
                continue;;
            $((${#subMenuAWS[@]}+1))) echo -e "\033[1;32mMain Menu!\033[1;36m"; break;;
            *) echo -e "\033[1;31m- $REPLY is invalid option. Try another one. -\033[1;36m";;
            esac
            REPLY=
        done;;
    2) echo -e "\033[1;32mYou chose $option\n\033[1;36m" 
        select optionDOCKER in "${subMenuDOCKER[@]}" "Back"; do 
            case "$REPLY" in
            1) echo -e "\033[1;32mYou chose $optionDOCKER\n\033[1;36m" 
                read -p "Enter absolute path to your compose file: " composeName 
                buildCompose
                REPLY=
                continue;;
            2) echo -e "\033[1;32mYou chose $optionDOCKER\n\033[1;36m" 
                read -p "Enter absolute path to your compose file: " composeName 
                read -p "Enter args: " args 
                buildComposeArgs
                REPLY=
                continue;;
            3) echo -e "\033[1;32mYou chose $optionDOCKER\n\033[1;36m" 
                read -p "Enter crawler name: " input 
                deleteLocalImage
                REPLY=
                continue;;
            4) echo -e "\033[1;32mYou chose $optionDOCKER\n\033[1;36m"  
                deleteDockerCache
                REPLY=
                continue;;
            $((${#subMenuDOCKER[@]}+1))) echo -e "\033[1;32mMain Menu!\033[1;36m"; break;;
            *) echo -e "\033[1;31m- $REPLY is invalid option. Try another one. -\033[1;36m";;
            esac
            REPLY=
        done;;
    $((${#menu[@]}+1))) echo -e "\033[1;31mGoodbye!"; break;;
    *) echo -e "\033[1;31m- $REPLY is invalid option. Try another one. -\033[1;36m";;
    esac
    REPLY=
done

# ----------------------------------------------------------------------------
# ------------------------       SCRIPT END      -----------------------------
# ----------------------------------------------------------------------------
