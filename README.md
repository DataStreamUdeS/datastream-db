# datastream-db
DataStream Data Base creation script. Create schema with PostgreSQL

En cas d'impossibilité de connexion au service local, vérifier si un service "postgresqlxxx" n'est pas en exécution
Marche à suivre : windows->"Services", trouvé le service "postgresql..." et cliquer sur "disable" et "stop"
Vérifier également qu'aucune autre instance de PostgrSQL ne roule en arrière plan
Un fichier .bat se trouve dans /debug pour lister les process qui utilisent le post 5432