function split(str,sep) --splits a string by the seperator
    local array = {}
    local reg = string.format("([^%s]+)",sep)
    for mem in string.gmatch(str,reg) do
        table.insert(array, mem)
    end
    return array
end

function loadcsv(name) 
 local file=io.open(name,"r");
 local toreturn={}
 for line in file:lines() do
 	if(string.match(line,",,")) then goto skip end
 table.insert(toreturn,split(line,","))
 ::skip::
 end
return toreturn
end

occurances={}

local translated = io.open("translated.csv", "r"); --opens the file 
 local translation_table = {} --table/hashmap datastructure to hold translations
 for line in translated:lines() do
 	occurances[split(line,",")[2]]=0
 	--datastructure: english,fragile,compressible,special,amount,mean volume,sd volume,mean weight
    translation_table[split(line,",")[1]]={split(line,",")[2],split(line,",")[3],split(line,",")[4],split(line,",")[5],0,0,0,0};
 end

---

local product_dataset=loadcsv("products.csv")
 products_hmap={}


for i=2,#product_dataset-1,1  do 
	
    products_hmap[product_dataset[i][1]]={product_dataset[i][2],product_dataset[i][6],product_dataset[i][7],product_dataset[i][8],product_dataset[i][9]}
    t=products_hmap[product_dataset[i][1]][1]
    
    occurances[translation_table[t][1]]=occurances[translation_table[t][1]]+1

end
local translated = io.open("translated.csv", "r"); --opens the file 

for line in translated:lines() do --for loop to initialise data point in translation_table of amount 
 splitLine=split(line,",")
 translation_table[splitLine[1]][5]=occurances[splitLine[2]]
 print("Item: "..splitLine[2].." occours "..occurances[splitLine[2]].." times.") --print occurances
end

fragile=0
compressible=0
special=0

meanX=0
meanY=0
meanZ=0


local product_dataset=loadcsv("products.csv")
for i=2,#product_dataset  do 
	--data struct: category,weight,x,y,z
    products_hmap[product_dataset[i][1]]={product_dataset[i][2],product_dataset[i][6],product_dataset[i][7],product_dataset[i][8],product_dataset[i][9]}
    volume=tonumber(product_dataset[i][7])*tonumber(product_dataset[i][8])*tonumber(product_dataset[i][9]) --volume in cubic centiliters
    translation_table[product_dataset[i][2]][6]=volume/tonumber(translation_table[product_dataset[i][2]][5])
    t=products_hmap[product_dataset[i][1]][1]

    translation_table[product_dataset[i][2]][7]=translation_table[product_dataset[i][2]][7]+(math.pow(volume-translation_table[product_dataset[i][2]][6],2)/translation_table[product_dataset[i][2]][5])
   
    if(string.match(translation_table[product_dataset[i][2]][3],"Y")=="Y") then fragile =fragile +1 end
    if(string.match(translation_table[product_dataset[i][2]][4],"Y")=="Y") then compressible =compressible +1 end
	if(string.match(translation_table[product_dataset[i][2]][5],"Y")=="Y") then special =special +1 end

	translation_table[product_dataset[i][2]][8]=translation_table[product_dataset[i][2]][8]+(product_dataset[i][5]/translation_table[product_dataset[i][2]][5])
	meanX=meanX+product_dataset[i][7]
	meanY=meanY+product_dataset[i][8]
	meanZ=meanZ+product_dataset[i][9]
end

--loop one last time over translation_table to take the square root of the thing
local translated = io.open("translated.csv", "r"); --opens the file 

for line in translated:lines()  do 
	
    translation_table[split(line,",")[1]][7]=math.sqrt(translation_table[split(line,",")[1]][7])
    print("STANDARD DEVIATION FOR: "..split(line,",")[2].." : "..math.pow(translation_table[split(line,",")[1]][7],1/6))
    print("MEAN WEIGHT FOR: "..split(line,",")[2].." : "..translation_table[split(line,",")[1]][8])
end

local pLength=32951 --length of product dataset

print("FRAGILE ITEMS: "..fragile)
print("COMPRESSIBLE ITEMS: "..compressible)
print("SPECIAL ITEMS: "..special)
print("MEAN X SIZE OF BOX: "..(meanX/pLength))
print("MEAN Y SIZE OF BOX: "..(meanY/pLength))
print("MEAN Z SIZE OF BOX: "..(meanZ/pLength))
print("ALL WEIGHT MEASUREMENTS IN KILOGRAMS, VOLUME MEASUREMENTS IN CUBIC CENTILITERS, LENGTH MEASUREMENTS IN CENTIMETERS")
