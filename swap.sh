#!/bin/bash
echo "Введите количесво памяти в (Мбайт, к примеру 512 или 1024) выделяемое для swap файла. Рекомендуемо (Объём ОЗУ или двойной объём ОЗУ)"
read sizeSwapFile
echo "Введите путь, где будет распологаться swap файл. Рекомендуемо (/)"
read path
echo "Введите имя swap файла. Рекомендуемо (swapFile)"
read name
freePlace=$(df -hk $path | awk 'NR==2{print $4}')
tmp=$((sizeSwapFile*1024))
if [ "$freePlace" -gt "$tmp" ]
then
	echo "Подождите, создаётся swap файл"
	if dd if=/dev/zero of=$path$name bs=1024 count=$sizeSwapFile\K
	then
		echo "1) [Swap файл создан успешно!]"
		if chmod 600 $path$name && mkswap $path$name
		then
			echo "2) [Права на файл и запись системной информации в swap файл успешна!]"
			if swapon $path$name
			then
				echo "3) [Активация swap файла успешна!]"
				if echo "# Файл подкачки (swap)" | tee -a /etc/fstab
				then
					echo "$path$name swap swap defaults 0 0" | tee -a /etc/fstab
					echo "4) [Запись автозапуска swap файла добавлена в /etc/fstab успешно!]"
					cat /proc/swaps
				else
					echo "4) [Внимание !!! Запись автозапуска swap файла в /etc/fstab не добавлена!]"
				fi
			else
				echo "3) [Внимание !!! Активация swap файла не удалась!]"
			fi
		else
			echo "2) [Внимание !!! Права на файл и запись системной информации в swap не удалась!]"
		fi
	else
		echo "1) [Внимание !!! Swap файл создать не удалось!]"
	fi
else
	echo "У вас не достаточно места на жёстком диске"
fi


