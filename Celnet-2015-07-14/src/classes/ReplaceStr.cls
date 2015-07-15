public with sharing class ReplaceStr {
    public String repla(String str,Integer size){
        String tempStr = '';
        Integer startSize =0;
        Integer endSize = size;
        for(Integer i = 0;i <= str.length()/size ;i++)
        {
        	if(endSize>=str.length()){
                endSize=str.length();
            }
            tempStr=tempStr+'\n'+str.substring(startSize,endSize);
            startSize = startSize+size;
            endSize = endSize+size;
            
        }
        return tempStr;
    }
}