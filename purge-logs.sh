# Le script suivant va archiver les enregistrements vieux de plus de 7 jours
# et les placer dans le dossier /var/backups/syslog du serveur de logs.
# Dans un second temps, il va supprimer ces memes enregistrements directement
# dans la base de donnees.

# Vous pouvez definir vous-meme la duree de retention des logs, le repertoire
# de stockage des archives ainsi que leur nom dans la partie « Declaration
# des parametres d’archivage ».

# Renseignez vos propres informations de base de donnees dans la partie
# « Declaration des parametres de database » (attention à la casse).


#!/bin/bash

################################################
#    Declaration des parametres d’archivage    #
################################################

RETENTION=7                                     # Duree de retention des logs (en jours)
DESTDIR="/var/backups/syslog"                   # Repertoire de stockage des archives
ARCHIVE="syslog-$(date '+%Y-%m-%d-%Hh%M').gz"   # Nom des archives

################################################
#    Declaration des parametres de database    #
################################################

MYSQL_HOST="localhost"                          # Nom ou adresse IP sur serveur hebergeant la base de donnees
MYSQL_DB="Syslog"                               # Nom de la base de donnees
MYSQL_USER="rsyslog"                            # Utilisateur de la base de donnees
MYSQL_PASSWD="motdepasse-user-rsyslog"          # MDP de l’utilisateur precedent


### NE PAS MODIFIER A PARTIR DE CE POINT ###

# Lancement de l’archivage
sql_arch="SELECT * FROM SystemEvents WHERE DATEDIFF(NOW(), DeviceReportedTime) > $RETENTION"
mysql -h $MYSQL_HOST -u $MYSQL_USER –p $MYSQL_PASSWD -e "$sql_arch" -B -s $MYSQL_DB | gzip > $DESTDIR/$ARCHIVE


# Suppression des evenements en base de donnees
sql_del="DELETE FROM SystemEvents WHERE DATEDIFF(NOW(), DeviceReportedTime) > $RETENTION"
mysql -h $MYSQL_HOST -u $MYSQL_USER –p $MYSQL_PASSWD -e "$sql_del" -B -s $MYSQL_DB
