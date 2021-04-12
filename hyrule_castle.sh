#!/bin/bash
perso_id_max=100
id_plus=200
id_boss=100
nb_etage=1
choix=$1
choix_perso=0
choix_final=0

random () {
    while [[ $choix_perso -le 0 ]]; do
    choix_perso=$RANDOM
    let "choix_perso %= $perso_id_max"
    done
}

rareter() {
    if [[ $choix_perso -gt 0 ]] && [[ $choix_perso -le 50 ]]; then
	rareter="1"
    fi
    if [[ $choix_perso -gt 50 ]] && [[ $choix_perso -le 80 ]]; then
	rareter="2"
    fi
    if [[ $choix_perso -gt 80 ]] && [[ $choix_perso -le 95 ]]; then
	rareter="3"
    fi
    if [[ $choix_perso -gt 95 ]] && [[ $choix_perso -le 99 ]]; then
	rareter="4"
    fi
    if [[ $choix_perso -gt 99 ]] && [[ $choix_perso -le 101 ]]; then
	rareter="5"
    fi
}

randome_plus () {
    while [[ $choix_final -le 0 ]]; do
	choix_final=$RANDOM
	let "choix_final %= $id_plus"
    done
    if [[ $choix_final -gt 0 ]] && [[ $choix_final -le 50 ]]; then
	id_final=${tableau[0]}
    fi
    if [[ $choix_final -gt 50 ]] && [[ $choix_final -le 100 ]]; then
	id_final=${tableau[1]}
    fi
    
    if [[ $choix_final -gt 100 ]] && [[ $choix_final -le 150 ]]; then
	id_final=11
    fi
    if [[ $choix_final -gt 150 ]] && [[ $choix_final -le 200 ]]; then
            id_final=12
    fi
}

randome_boss () {
    while [[ $choix_final -le 0 ]]; do
        choix_final=$RANDOM
        let "choix_final %= $id_boss"
    done
    if [[ $choix_final -gt 0 ]] && [[ $choix_final -le 50 ]]; then
        id_final=${tableau[0]}
    fi
    if [[ $choix_final -gt 50 ]] && [[ $choix_final -le 100 ]]; then
        id_final=${tableau[1]}
    fi
}


personage() {
    while IFS=',' read -r id name hp mp str int def res spd luck race class rarity; do
	if [[ $1 == $rarity ]]; then
	    nom_perso=$name
	    echo -e "\033[36m You play\033[0m \033[32m$nom_perso.\033[0m"
	    echo -e "\033[36m Kill all enemies and save the princess.\033[0m"
	    vie_perso=$hp
	    echo -e "\033[36m That it's your HP:\033[0m \033[32m$vie_perso.\033[0m"
	    vie_perso_max=$hp
	    force_perso=$str
	    echo -e "\033[36m That it's your Damage:\033[0m \033[31m$force_perso.\033[0m"
	fi
    done < players.csv
}

ennemi() {
    while IFS=',' read -r id name hp mp str int def res spd luck race class rarity; do
	if [[ $1 == $rarity ]]; then
	    tableau+=($id)
	    randome_plus
	fi
	if [[ $id_final == $id ]]; then
	    nom_ennemi=$name
	    echo -e "\033[32m =====================\033[0m"
	    echo -e "\033[36m Be careful there is an enemy in front of you.\033[0m" 
	    echo -e "\033[36m His name is\033[0m \033[31m$nom_ennemi.\033[0m"
	    vie_ennemi=$hp
	    echo -e "\033[36m Enemy's HP:\033[0m \033[32m$vie_ennemi.\033[0m"
	    force_ennemi=$str
	    echo -e "\033[36m Enemy's Damage:\033[0m \033[31m$force_ennemi.\033[0m"
	    echo -e "\033[31m =====================\033[0m"
	fi
    done < enemies.csv
} 

boss () {
    while IFS=',' read -r id name hp mp str int def res spd luck race class rarity; do
	if [[ $1 == $rarity ]]; then
	    tableau+=($id)
	    randome_boss
	fi
	if [[ $id_final == $id ]]; then
	    echo -e "\033[32m=====================\033[0m"
	    nom_ennemi=$name
	    echo -e "\033[36m Be careful there is the BOSS in front of you.\033[0m"
	    echo -e "\033[36m His name is\033[0m \033[31m$nom_ennemi.\033[0m"
	    vie_ennemi=$hp
	    echo -e "\033[36m Enemy's HP:\033[0m \033[32m$vie_ennemi.\033[0m"
	    force_ennemi=$str
	    echo -e "\033[36m Enemy's Damage:\033[0m \033[33m $force_ennemi.\033[0m"
	    echo -e "\033[32m=====================\033[0m"
	fi
    done < bosses.csv
}

combat() {
    while [[ $vie_perso -gt 0 ]] && [[ $vie_ennemi -gt 0 ]]; do
	PS3="choose one :"
	action=("Attack" "Heal")
	select choix in "${action[@]}"; do
	    case $choix in
	        "Attack")
		    echo -e "\033[31m =====================\033[0m"
		    echo -e "\033[32m $nom_perso\033[0m \033[36mattack !\033[0m"
		    echo -e "\033[32m $nom_perso\033[0m \033[36mdone\033[0m \033[31m$force_perso\033[0m \033[36mdamage.\033[0m"
		    vie_ennemi=$(($vie_ennemi-$force_perso))
		    echo -e "\033[36m Enemy's HP: $vie_ennemi\033[0m"
		    break
		    ;;
		"Heal")
		    echo -e "\033[31m =====================\033[0m"
		    echo -e "\033[32m $nom_perso\033[0m \033[36mtake a potion! Be careful don't drive after that!\033[0m"
		    vie_perso=$(($vie_perso+($vie_perso_max/2)))
		    if [[ $vie_perso -gt $vie_perso_max ]]; then
			vie_perso=$vie_perso_max
			echo -e "\033[36m Your HP:\033[0m \033[32m$vie_perso\033[0m"
		    fi
		    break
		    ;;
		*) echo "Nope"
	    esac
	done
	if [[ $vie_ennemi -gt 0 ]]; then
	    echo -e "\033[31m =====================\033[0m"
	    echo -e "\033[31m $nom_ennemi\033[0m \033[36mattack!\033[0m"
	    echo -e "\033[31m $nom_ennemi\033[0m \033[36mdone\033[0m \033[31m$force_ennemi\033[0m \033[36mdamage.\033[0m"
	    vie_perso=$(($vie_perso-$force_ennemi))
	    echo -e "\033[36m Your HP:\033[0m \033[32m$vie_perso\033[0m"
	    echo -e "\033[31m =====================\033[0m"
	fi
    done
    if [[ $vie_perso -le 0 ]]; then
	echo -e "\033[31m    GAME OVER    \033[0m"
	echo -e "\033[31m =====================\033[0m"
	exit
    fi
    nb_etage=$(($nb_etage+1))
}


etage () {
    while [[ $nb_etage -le 10 ]]; do
	if [[ $nb_etage == 10 ]]; then
	    tableau=()
	    choix_perso=0
	    choix_final=0
	    random
	    rareter "$choix_perso"
	    boss "$rareter"
	    combat
	    echo -e "\033[32m =====================\033[0m"
	    echo -e "\033[36m Nice fight! The Princess is save!\033[0m"
	    echo -e "\033[33m ====================\033[0m"
	    echo -e "\033[32m     FELICITATION     \033[0m"
	    echo -e "\033[33m ====================\033[0m"
	else
	    tableau=()
	    choix_perso=0
	    choix_final=0
	    random
	    rareter
	    ennemi "$rareter"
	    combat
	    clear
	    echo -e "\033[32m =====================\033[0m"
	    echo -e "\033[36m Nice fight! Now go to the next floor!\033[0m"
	fi
    done
}
clear
echo -e "\033[32m =====================\033[0m"
echo -e "\033[36m -------WELCOME-------\033[0m"
echo -e "\033[32m =====================\033[0m"
echo -e "\033[36m You enter into the Hyrule Castle.\033[0m"
echo -e "\033[32m =====================\033[0m"
random
rareter "$choix_perso"
personage "$rareter"
etage
