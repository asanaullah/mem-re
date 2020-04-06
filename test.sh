TTY=/dev/ttyUSB3
NUL=/dev/null
FILE=log.txt
TEMP=temp.bin




write () {
 A0=$((ADDRESS&255)) 
 A0=$(printf "\x$(printf %x $A0)")
 A1=$(((ADDRESS>>8)&255))
 A1=$(printf "\x$(printf %x $A1)")
 A2=$(((ADDRESS>>16)&255)) 
 A2=$(printf "\x$(printf %x $A2)")
 A3=$(((ADDRESS>>24)&255))
 A3=$(printf "\x$(printf %x $A3)")
 D0=$(((DATA_0>>0)&255))
 D0=$(printf "\x$(printf %x $D0)")
 D1=$(((DATA_0>>8)&255))
 D1=$(printf "\x$(printf %x $D1)")
 D2=$(((DATA_0>>16)&255))
 D2=$(printf "\x$(printf %x $D2)")
 D3=$(((DATA_0>>24)&255))
 D3=$(printf "\x$(printf %x $D3)")
 D4=$(((DATA_1>>0)&255))
 D4=$(printf "\x$(printf %x $D4)")
 D5=$(((DATA_1>>8)&255))
 D5=$(printf "\x$(printf %x $D5)")
 D6=$(((DATA_1>>16)&255))
 D6=$(printf "\x$(printf %x $D6)")
 D7=$(((DATA_1>>24)&255))
 D7=$(printf "\x$(printf %x $D7)")
 D8=$(((DATA_2>>04)&255))
 D8=$(printf "\x$(printf %x $D8)")
 D9=$(((DATA_2>>8)&255))
 D9=$(printf "\x$(printf %x $D9)")
 D10=$(((DATA_2>>16)&255))
 D10=$(printf "\x$(printf %x $D10)")
 D11=$(((DATA_2>>24)&255))
 D11=$(printf "\x$(printf %x $D11)")
 D12=$(((DATA_3>>0)&255))
 D12=$(printf "\x$(printf %x $D12)")
 D13=$(((DATA_3>>8)&255))
 D13=$(printf "\x$(printf %x $D13)")
 D14=$(((DATA_3>>16)&255))
 D14=$(printf "\x$(printf %x $D14)")
 D15=$(((DATA_3>>24)&255))
 D15=$(printf "\x$(printf %x $D15)")
 printf "1"$A0$A1$A2$A3$D0$D1$D2$D3$D4$D5$D6$D7$D8$D9$D10$D11$D12$D13$D14$D15 > ${TTY}
 printf "1"$A0$A1$A2$A3$D0$D1$D2$D3$D4$D5$D6$D7$D8$D9$D10$D11$D12$D13$D14$D15"\n"
}


readd () {
 A0=$((ADDRESS&255)) 
 A0=$(printf "\x$(printf %x $A0)")
 A1=$(((ADDRESS>>8)&255))
 A1=$(printf "\x$(printf %x $A1)")
 A2=$(((ADDRESS>>16)&255)) 
 A2=$(printf "\x$(printf %x $A2)")
 A3=$(((ADDRESS>>24)&255))
 A3=$(printf "\x$(printf %x $A3)")
 printf "0"$A0$A1$A2$A3 > ${TTY}
}



busy () {
 echo "Command: Busy"
 printf "2" > ${TTY}
}


BANK=0x2
ROW=0xC4C
COL=0x131
DATA_0=0x61616161
DATA_1=0x61616161
DATA_2=0x61616161
DATA_3=0x61616161
ADDRESS=$(((BANK<<23)|(ROW<<10)|COL))

 
# 

#ADDRESS=0x31313131
echo "Adress: " $ADDRESS
A0=$((ADDRESS&255)) 
A0=$(printf '%02x' $A0)
A1=$(((ADDRESS>>8)&255))
A1=$(printf '%02x' $A1)
A2=$(((ADDRESS>>16)&255)) 
A2=$(printf '%02x' $A2)
A3=$(((ADDRESS>>24)&255))
A3=$(printf '%02x' $A3)
echo "Hex Address: 0x"$A3$A2$A1$A0 

BANK=0x2
ROW=0x0C40
COL=0x135
DATA_0=0x62626262
ADDRESS=$(((BANK<<23)|(ROW<<10)|COL))


for j in {1..8}
do
echo "Bank: " $BANK
for i in {1..26} 
do
#write
write
ROW=$((ROW+0x0008))
DATA_0=$((DATA_0 + 0x01010101))
ADDRESS=$(((BANK<<23)|(ROW<<10)|COL))
done
BANK=$((BANK+0x1))
DATA_0=0x62626262
done

BANK=0x2

ROW=0x0C40
DATA_0=0x61616161
ADDRESS=$(((BANK<<23)|(ROW<<10)|COL))

for j in {1..8}
do
echo "BANK: " $BANK
for i in {1..26} 
do
readd
sleep 0.1
ROW=$((ROW+0x0008))
DATA_0=$((DATA_0 + 0x01010101))
ADDRESS=$(((BANK<<23)|(ROW<<10)|COL))
done
BANK=$((BANK+0x1))
done