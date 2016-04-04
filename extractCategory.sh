category=`curl http://www.pornhd.com/category`
#category=`cat pagina.html`
filttroInizioCategory='\<ul class=\"categories-all\">'
filttroFineCategory='\<\/ul\>*\<div class=\"footer\-zone\">'
inizioCategory=${category#*$filttroInizioCategory} # trova l'inizio delle categorie nella paggina scaricata
fineCategory=${inizioCategory%%$filttroFineCategory*} # vi si trova l'ul delle categorie


inizioLiURL='\<a class=\"name\" href=\"'
fineLiURL='\"\>'
fineTitolo='\<\/a\>*\<\/li\>'

for li in $(echo $fineCategory | tr " " "\n"); do
	if [[ $li == href\=\"* ]]; then
		
		if [[ $bool == false ]]; then
			url=${li:6:-2}
			tempURL=\ $url
			archiveURL=$archiveURL$tempURL # archivio di url
			tempNomeCategorie=\ ${url:10:-7}
			archiveNameCategory=$archiveNameCategory$tempNomeCategorie # nomi categorie con trattino sugli spazzi
			nCategorie=$(($nCategorie+1)) #numero delle categorie
			bool=true
			
		else
			bool=false
		fi
	fi
done

mkdir Download; cd Download

inizioDB='\<ul class=\"thumbs\"\>'
fineDB='\<\/ul\>'
inizioPublicita='\<li\>*\<div class=\"video\-thumb\-ad\-zone\"\>'
finePublicita='\<\/script\>*\<\/li\>'
finePublicita2='PornHD*Sex*Cam*\<\/span\>*\<\/li\>'
finePublSpecial=\<\/script\>\ \<\/li\>
finePublSpecial2=\<\/span\>\ \<\/li\>

for categoria in $(echo $archiveNameCategory | tr " " "\n"); do
	echo $categoria >> categoria.db
	mkdir $categoria; cd $categoria
	CategoriaUltimatePage=`curl http://www.pornhd.com/category/$categoria-videos?page=1000`
	#CategoriaUltimatePage=`curl http://www.pornhd.com/category/indian-videos?page=1000`
	b="<ul class=\"\">"
	c="</ul>"
	i=">"
	m="</a>"
	d=${CategoriaUltimatePage#*$b}
	e=${d%%$c*}
	g=${e%$m*}
	h=${g##*$i}
	if [[ $h == PornHD\ Prime ]]; then
		page=`curl http://www.pornhd.com/category/$categoria-videos`
		buffer=${page#*$inizioDB} #mostra tutto quello che ce dentro $sito dopo il punto $inizioDB
		DB=${buffer%%$fineDB*} #mostra quello che ce in $buffer fino a $fineDB 
		parte1DB=${DB%$inizioPublicita*} #salva in $parte1DB quello che c'e prima di $inizioPubl del $DB generale
		if `echo $DB | grep -q "</script> </li>"`; then
			parte2DB=${DB#*$finePublicita} #mostra quello che ce in $DB dopo $finePubl
		fi
		if `echo $DB | grep -q "PornHD Sex Cam </span> </li>"`; then
			parte2DB=${DB#*$finePublicita2} #mostra quello che ce in $DB dopo $finePubl
		fi
		DBPulito=$parte1DB$parte2DB #riunisce il file da $g con $i
		echo $DBPulito > 1
	else
		h=$(($h+1))
		for (( i = 1; i < $h; i++ )); do
			page=`curl http://www.pornhd.com/category/$categoria-videos?page=$i`
			#page=`curl http://www.pornhd.com/category/big-ass-videos?page=$i`

			buffer=${page#*$inizioDB} #mostra tutto quello che ce dentro $sito dopo il punto $inizioDB
			DB=${buffer%%$fineDB*} #mostra quello che ce in $buffer fino a $fineDB 
			#nel DB ci sono tutti gli li ma e presente anche publicita

			#elliminazione publicita da $DB
			parte1DB=${DB%$inizioPublicita*} #salva in $parte1DB quello che c'e prima di $inizioPubl del $DB generale
			if `echo $DB | grep -q "</script> </li>"`; then
				parte2DB=${DB#*$finePublicita} #mostra quello che ce in $DB dopo $finePubl
			fi
			if `echo $DB | grep -q "PornHD Sex Cam </span> </li>"`; then
				parte2DB=${DB#*$finePublicita2} #mostra quello che ce in $DB dopo $finePubl
			fi
			DBPulito=$parte1DB$parte2DB #riunisce il file da $g con $i
			#DBPulito contiene tutti gli li senza publicita
			echo $DBPulito > $i
		done
	fi
	
	cd ../
done



