/*
Copyright (c) 2012, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/* HVEMKnowledgeArticleCtrl Class
 * This class is used to process the Knowledge Article actions.
 */
public with Sharing class HVEMKnowledgeArticleCtrl{

    public Case caseInstance{get;set;}
    public HVEM_Config_Options__c hvemsettingsIns{get;set;}
    public HVEMDBhelper dbHelper{get;set;}
    public HVEMConditionBuilder lCondition{get;set;}
    public HVEMConditionBuilder lConditionForCase{get;set;}

    public boolean noArticlesToFilterError{get;set;}

    public String subjectFilter{get;set;}
    public String articleTypesForFilter{get;set;}
    public String categoryGroupsForFilter{get;set;}
    private static final String NON_BREAKING_SPACE = '&nbsp;&nbsp;';
    //private final String KNOWLEDGEARTICLES = 'KnowledgeArticleVersion';
    public String selectedKnowledgeArticleURL{get;set;}
    public String selectedKnowledgeArticleLanguage{get;set;}
    public String selectedKnowledgeArticleFrameSource{get;set;}
    public String baseURL{get;set;}
    public String calledFrom{get;set;}
    public String display{get;set;}
    public boolean subjectBlankError{get;set;}
    public String articleTypeOfSelectedArticle{get;set;}
    public String articleTitle{get;set;}
    public String articleSummary{get;set;}
    public String withDataCategoryClause{get;set;}
    public String selectedLanguage{get; set;}
    public String templateType{get;set;}


    public Integer categoryGroupCount{get;set;}
    public Integer filteredKnowledgeArticlesSize{get;set;}

    public List<String> selectedCatagoriesList{get;set;}
    public List<String> selectedArticleTypes{get;set;}
    public List<HVEMKnowledgeArticleStructure> filteredKnowledgeArticles{get;set;}
    public List<String> categoryGroupsFromHVEMList{get;set;}
    public List<KnowledgeArticleLabelValue> knowledgeArticleLabelValueList{get;set;}
    private List<String> showFilterList{get;set;}
    private List<String> articleTypeDisplayList{get;set;}
    public List<String> categoryGroupDisplayList{get;set;}
    private List<HVEM_Config_Options__c> hvemCaseFilterList{get;set;}

    public ID caseId {get; set;}
    public ID selectedKaId{get;set;}
    public ID selectedKavId{get;set;}
    public Boolean isAttached{get; set;}
    public String articleName {get; set;}

    public boolean IsVisiblePKB{get;set;}
    public boolean IsVisiblePRM{get;set;}
    public boolean IsVisibleCSP{get;set;}

    public String CSPChannelVisible{get;set;}
    public String PKBChannelVisible{get;set;}
    public String PRMChannelVisible{get;set;}

    public List<String> articleContentList{get;set;}
    public Boolean isInsertingContent{get;set;}
    /**
     *Constructor
     */
    public HVEMKnowledgeArticleCtrl(){
        selectedArticleTypes = new List<String>();
        articleTypeDisplayList = new List<String>();
        categoryGroupDisplayList = new List<String>();
        selectedCatagoriesList = new List<String>();
        articleContentList = new List<String>();
        hvemCaseFilterList = new List<HVEM_Config_Options__c>();
        showFilterList = new List<String>();
        categoryGroupsFromHVEMList = new List<String>();
        dbHelper = new HVEMDBhelper();
        noArticlesToFilterError = false;
        withDataCategoryClause = '';
        selectedKnowledgeArticleLanguage = '';
        //baseUrl populated which is used to display the KnowledgeArticles in IFrame on the RightSide component
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/articles/';

        //Query to get the Custom seeting for name not equals 'HVEM'(for applying the case filters)
        lCondition = new HVEMConditionBuilder();
        lCondition.setCondition('name != \'HVEM\'');
        hvemCaseFilterList = dbHelper.getQueryResults(new HVEM_Config_Options__c(),null,lCondition);

        subjectBlankError = false;
        caseId = ApexPages.currentPage().getParameters().get('Id');

        //Query to get the case details according to the caseId received.
        lConditionForCase = new HVEMConditionBuilder();
        lConditionForCase.setCondition('Id=\''+caseId+'\'');
        List<Case> caseList = dbHelper.getQueryResults(new Case(),null,lConditionForCase);
        caseInstance = new Case();
        caseInstance = caseList[0];
        subjectFilter = caseInstance.subject;

        //get the custom setting with name equals 'HVEM'
        hvemSettingsIns = new HVEM_Config_Options__c();
        hvemSettingsIns = HVEM_Config_Options__c.getInstance('HVEM');

        if(hvemSettingsIns != null){

            articleTypesForFilter = hvemSettingsIns.Article_Types_Filter__c;
            categoryGroupsForFilter = hvemSettingsIns.Data_Category_Group_Filter__c;

            IsVisiblePRM = hvemSettingsIns.Check_PRM_Channel__c;
            IsVisiblePKB = hvemSettingsIns.Check_PKB_Channel__c;
            IsVisibleCSP = hvemSettingsIns.Check_CSP_Channel__c;

            PRMChannelVisible = hvemSettingsIns.PRM_Channel_Available__c;
            PKBChannelVisible  = hvemSettingsIns.PKB_Channel_Available__c;
            CSPChannelVisible = hvemSettingsIns.CSP_Channel_Available__c;
            isInsertingContent = hvemSettingsIns.Insert_KB_Article_Content__c;

            articleTypeDisplayList = hvemSettingsIns.Article_Types_Filter__c.split(',');
            if((hvemSettingsIns.Data_Category_Group_Filter__c != null) &&(hvemSettingsIns.Data_Category_Group_Filter__c.length()>0 )){
                categoryGroupDisplayList = hvemSettingsIns.Data_Category_Group_Filter__c.split(',');
            }
            if((hvemSettingsIns.Languages_Selected__c != null) &&(hvemSettingsIns.Languages_Selected__c.length()>0 )){
                selectedLanguage = hvemSettingsIns.Languages_Selected__c.split(',')[0];
                User userInstance = [SELECT Id,languageLocaleKey FROM User WHERE Id=: userInfo.getUserId()];
                for(String lang : hvemSettingsIns.Languages_Selected__c.split(',')){
                    if(lang == userInstance.languageLocaleKey){
                        selectedLanguage = lang;
                        break;
                    }
                }
            }
        }else{
            selectedLanguage = 'en_US';
        }

        selectedArticleTypes = articleTypeDisplayList.clone() ;

        //call to the function that sets the filter criterion according to the specifications in HVEM settings
        initializeCategoryGroupsFromHVEMList();
        prepareWithDataCategoryString();

        categoryGroupCount = categoryGroupDisplayList.size();
        calledFrom='constructor';

        //call to the function to filter according to the Case filter mapping in HVEM settings.
        filterArticleList();
    }

    /*
     * Functon to attach Article to Case in CaseArticle object
     */
    public void attachArticle(){
        List<CaseArticle> ca = [select ID from CaseArticle where CaseId =: caseId and KnowledgeArticleId =: selectedKaId];
        if (!ca.isEmpty()) {
            // the link already exist, we should not insert a new one
            return;
        }
        CaseArticle caseArticleInstance = new CaseArticle();
        caseArticleInstance.CaseId = caseId;
        caseArticleInstance.KnowledgeArticleId = selectedKaId;
        insert caseArticleInstance;

    }

    /**
     * function to fetch the categories to be applied at load time to the filter.
     */
    public void initializeCategoryGroupsFromHVEMList(){
        for(HVEM_Config_Options__c caseFilterMap : hvemCaseFilterList){
            List<String> caseFilterMapList = caseFilterMap.Case_Mappin_API__c.split(' >> ');
            List<String> fieldMapList = caseFilterMapList[0].split(':',2);
            List<String> categoryDataCategoryList = caseFilterMapList[1].split(':',2);
            if(caseInstance.get(fieldMapList[0]) == fieldMapList[1]){
                for(String specifiedCategoryGroup : categoryGroupDisplayList){
                    if(categoryDataCategoryList[0] == specifiedCategoryGroup){
                        categoryGroupsFromHVEMList.add(caseFilterMapList[1]);
                    }
                }
            }
        }
    }

    /**
     * Function to get the Article Types.
     */
    public List<SelectOption> getArticleTypesDevName() {
        List<SelectOption> options = new List<SelectOption>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();

        for(Schema.SObjectType f : gd) {
            if (f.getDescribe().getName().endsWith('__kav')) {
                for(String articleTypesInSettings : articleTypeDisplayList){
                    if(f.getDescribe().getName() == articleTypesInSettings){
                        options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
                    }
                }
            }
        }
        return options;
    }

    /**
     * Function to prepare Data Category String for query
     */
    private void prepareWithDataCategoryString(){
        try{
            for(String singleGroupCategoryCombination : categoryGroupsFromHVEMList){
                List<String> CategoryGroupDataCategoryList = singleGroupCategoryCombination.split(':',2);
                withDataCategoryClause += CategoryGroupDataCategoryList[0] +'__c ABOVE_OR_BELOW ' + CategoryGroupDataCategoryList[1] + '__c AND ';
            }
            if(withDataCategoryClause.endsWith(' AND ')) {
                withDataCategoryClause = withDataCategoryClause.subString(0,(withDataCategoryClause.length()-4));
            }
            if((withDataCategoryClause != null) && (withDataCategoryClause != '')) {
                withDataCategoryClause = Label.Data_category + '  ' +  withDataCategoryClause;
            }
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
    }

    /**
     * Function that prepares a well formatted String of the Selected Article types.
     */
    private String prepareArticleTypeToQuery(){
        String articleTypeToQuery = '';
        if(selectedArticleTypes.size() == 0){
            selectedArticleTypes = articleTypeDisplayList.clone() ;
        }
        for(String singleArticleType : selectedArticleTypes){
            articleTypeToQuery += singleArticleType + '(Id, Title, Summary WHERE PublishStatus=\'online\' AND language=\'' + selectedLanguage + '\'), ';
        }
        if(articleTypeToQuery.endsWith(', ')){
            articleTypeToQuery = articleTypeToQuery.subString(0,(articleTypeToQuery.length()-2));
        }
        return articleTypeToQuery;
    }
    /**
      Function that return a string which is used for channel visibilty
    */
    Public String channelVisibility(){
        String channelVisible = '';
        if(IsVisiblePKB == true){
            if(PKBChannelVisible  == Label.Channel_Available){
                channelVisible = ' AND IsVisibleInPkb=true';
            }
            else{
                channelVisible = ' AND IsVisibleInPkb=false';
            }
        }

        if(IsVisiblePRM == true){
            if(PRMChannelVisible == Label.Channel_Available){
                channelVisible = channelVisible +' '+' AND IsVisibleInPrm=true';
            }else{
                channelVisible = channelVisible +' '+' AND IsVisibleInPrm=false';
            }
        }
        if(IsVisibleCSP == true){
            if(CSPChannelVisible == Label.Channel_Available){
                channelVisible = channelVisible +' '+' AND IsVisibleInCsp=true';
            }else{
                channelVisible = channelVisible +' '+' AND IsVisibleInCsp=false';
            }
        }
        return channelVisible;

    }

    /**
     * Function that filters the Knowledge articles according to the DataCategory and Article type Selected.
     */
    public void filterArticleList(){
        String soslKnowledgeQuery = '';
        String soqlKnowledgeQuery = '';
        String soslQueryWithArticleTypes = '';
        String soqlQueryWithArticleTypes = '';
        String articleName = '';
        String articleLabel = '';
        String channelString = '';
        subjectBlankError=false;
        filteredKnowledgeArticlesSize = 0;
        selectedKavId = null;
        String articleTypeToQuery = prepareArticleTypeToQuery();
        filteredKnowledgeArticles = new List<HVEMKnowledgeArticleStructure>();
        List<KnowledgeArticleVersion> KnowledgeArticlesList;
        List<CaseArticle> lCaseArticleList = new List<CaseArticle>();
        lCaseArticleList = [Select KnowledgeArticleId, CaseId From CaseArticle WHERE CaseId =: caseId];
        isAttached = false;
        List<List<sobject>> unorderedKnowledgeArticlesList = new List<List<sObject>>();
        map<String,String> articleIdArticleTypeMap = new Map<String,String>();
        try{

            //processing if Search field is not blank.
            if((subjectFilter != null) && (subjectFilter != '')){
                //SOSL Query to fetch the knowledge Articles according to the
                channelString = channelVisibility();
                soslKnowledgeQuery = 'FIND \''+ String.escapeSingleQuotes(subjectFilter) +'\' RETURNING KnowledgeArticleVersion(Id,KnowledgeArticleId,title,Language,summary,UrlName,LastPublishedDate where publishStatus=\'online\' ' + channelString  + ' AND language=\'' + selectedLanguage + '\') ' + withDataCategoryClause ;
                List<List<sObject>> allSoslKnowledgeArticleList = search.query(soslKnowledgeQuery);
                if(allSoslKnowledgeArticleList.size() != 0){
                    KnowledgeArticlesList =  allSoslKnowledgeArticleList[0];
                }
                //SOSL query to Filter the Fetched articles according to the Articles and datacategories selected.
                soslQueryWithArticleTypes = 'FIND \''+ String.escapeSingleQuotes(subjectFilter) +'\' RETURNING '+ articleTypeToQuery ;
                if((articleTypeToQuery != null) && (articleTypeToQuery.length() > 0)){
                    unorderedKnowledgeArticlesList = search.query(soslQueryWithArticleTypes);
                }
            }
            //processing if search field is blank
            else{
                //SOQL Query to fetch the knowledge Articles according to the relevence and category groups.
                HVEMConditionBuilder lConditionForOrderedKnowledgeArticleSOQLQuery = new HVEMConditionBuilder();
                channelString = channelVisibility();
                lConditionForOrderedKnowledgeArticleSOQLQuery.setCondition('publishStatus=\'online\' ' + channelString + ' AND language=\'' + selectedLanguage + '\' '+withDataCategoryClause);
                KnowledgeArticlesList = dbHelper.getQueryResults(new KnowledgeArticleVersion(),null,lConditionForOrderedKnowledgeArticleSOQLQuery);
                unorderedKnowledgeArticlesList = new List<List<sObject>>();
                for(String singleArticleType : selectedArticleTypes){
                    List<sObject> singleUnorderedKnowledgeArticlesList = new List<sObject>();
                    soqlQueryWithArticleTypes = 'SELECT id FROM '+ singleArticleType +' WHERE publishStatus=\'online\' AND language=\'' + selectedLanguage + '\'';
                    singleUnorderedKnowledgeArticlesList = Database.query(soqlQueryWithArticleTypes);
                    if((singleUnorderedKnowledgeArticlesList != null) && (singleUnorderedKnowledgeArticlesList.size() != 0)){
                        unorderedKnowledgeArticlesList.add(singleUnorderedKnowledgeArticlesList);
                    }
                }
            }

            if(((KnowledgeArticlesList != null) && (unorderedKnowledgeArticlesList != null)) && ((KnowledgeArticlesList .size() > 0) && (unorderedKnowledgeArticlesList.size() > 0))){
                noArticlesToFilterError = false;
                for(Integer i=0;i<unorderedKnowledgeArticlesList.size();i++){
                    for(Integer j=0;j<unorderedKnowledgeArticlesList[i].size();j++){
                        articleIdArticleTypeMap.put(unorderedKnowledgeArticlesList[i][j].id, String.valueOf(unorderedKnowledgeArticlesList[i].getSObjectType())+' >> '+unorderedKnowledgeArticlesList[i].getSObjectType().getDescribe().getLabel());
                    }
                }

                Integer idx = 0;
                for(KnowledgeArticleVersion article : KnowledgeArticlesList){
                    if(articleIdArticleTypeMap.containsKey(article.id) &&  (filteredKnowledgeArticles.size() <= 49)){
                        String articleAPILabelString = articleIdArticleTypeMap.get(article.id);
                        List<String> articleAPILabelList = articleAPILabelString.split(' >> ',2);
                        if(lCaseArticleList.size() > 0){
                            for(CaseArticle caseArticleInstance : lCaseArticleList){
                                if(caseArticleInstance.KnowledgeArticleId == article.KnowledgeArticleId){
                                    isAttached = true;
                                }
                            }
                        }
                        if( (articleAPILabelList != null) && (articleAPILabelList.size() > 0)){
                            filteredKnowledgeArticles.add(new HVEMKnowledgeArticleStructure(article,articleAPILabelList[0],articleAPILabelList[1],isAttached,idx++));
                        }
                        isAttached = false;
                    }
                }
            }else if(hvemSettingsIns == null){
                noArticlesToFilterError = true;
                selectedLanguage = 'en_US';
            }

            filteredKnowledgeArticlesSize = filteredKnowledgeArticles.size();
            if((filteredKnowledgeArticles != null) && (filteredKnowledgeArticles.size() > 0)){
                selectedKavId = filteredKnowledgeArticles[0].getKnowledgeArticle().id;
                selectedKnowledgeArticleFrameSource = filteredKnowledgeArticles[0].getArticleName().subString(0,(filteredKnowledgeArticles[0].getArticleName().length()-5))+'/'+filteredKnowledgeArticles[0].getKnowledgeArticle().UrlName;
                articleTypeOfSelectedArticle = filteredKnowledgeArticles[0].getArticleName();
                articleTitle = filteredKnowledgeArticles[0].getKnowledgeArticle().title;
                articleSummary = filteredKnowledgeArticles[0].getKnowledgeArticle().summary;
            }
            else if((filteredKnowledgeArticles == null) || (filteredKnowledgeArticles.size() == 0)){
                selectedKnowledgeArticleFrameSource = null;
            }

            //call to the function that displayes the selected Knowledge Article.
            displayCustomArticle();

        }catch(SearchException e){
            subjectBlankError=true;
            selectedKnowledgeArticleFrameSource = null;
        }catch(QueryException qe){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error Has Occured Please Contact Your Administrator.'+ qe);
            ApexPages.addMessage(myMsg);
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error Has Occured Please Contact Your Administrator.'+e);
            ApexPages.addMessage(myMsg);
            selectedKnowledgeArticleFrameSource = null;
        }

    }

    /**
     * function to display the custom Knowledge Article Content.
     */
    public void displayCustomArticle() {
        try {
            knowledgeArticleLabelValueList = new List<KnowledgeArticleLabelValue>{};
            String ConditionForArticleObject = 'SELECT Id, title, Summary from '+articleTypeOfSelectedArticle+' WHERE Id=\''+selectedKavId+'\'';

            if((String.valueOf(selectedKavId) != null) && (String.valueOf(selectedKavId) != '')){
                List<sObject> articleTypeIns = DataBase.query(ConditionForArticleObject);
                HVEMConditionBuilder lConditionForArticleObject = new HVEMConditionBuilder();
                lConditionForArticleObject.setCondition('Id=\''+selectedKavId+'\'');
                List<sObject> articleTypeList = dbHelper.getQueryResults(articleTypeIns.getSObjectType().newSObject(),null,lConditionForArticleObject);

                Map<String, Schema.SObjectField> fieldMap = articleTypeIns.getSObjectType().getDescribe().fields.getMap();
                for(String key : fieldMap.keySet()){
                    if(key.endsWith('__c')){
                        Schema.SObjectField value = fieldMap.get(key);
                        Schema.DescribeFieldResult fieldResult = value.getDescribe();
                        String fieldLabel = String.valueOf(fieldResult.getLabel());
                        String fieldValue = String.valueOf(articleTypeList[0].get(key));
                        if((fieldValue != null) && (fieldValue != ' ')){
                            knowledgeArticleLabelValueList.add(new KnowledgeArticleLabelValue(fieldLabel, fieldValue));

                        }
                    }
                }
            }
        } catch(Exception e){
            ApexPages.addMessages(e);
        }
    }

    /**
    * Function to show language filter for selected languages
    **/
    public List<SelectOption> getUserLanguagesList(){
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.User.fields.getMap();
        List<SelectOption> options = new List<SelectOption>();
        Set<String> languageApiSet = new Set<String>();
        hvemSettingsIns = HVEM_Config_Options__c.getInstance('HVEM');
        if(hvemSettingsIns != null){
            if(hvemSettingsIns.Languages_Selected__c != null && hvemSettingsIns.Languages_Selected__c != ''){
                languageApiSet.addAll(hvemSettingsIns.Languages_Selected__c.split(',',0));
            }
            for(Schema.SObjectField value : fieldMap.values()){
                Schema.DescribeFieldResult fieldResult = value.getDescribe();
                String fieldName= String.valueOf(fieldResult.getName());
                if(fieldName == 'LanguageLocaleKey'){
                    List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues();
                    for(Schema.PicklistEntry item : pickListValues){
                        if(languageApiSet.contains(item.getValue())){
                            options.add(new SelectOption(item.getValue(),item.getLabel()));
                        }
                    }
                }
            }
        }else{
            //set english as default language
            options.add(new SelectOption('en_US','English'));
        }
        return options;
    }

    /**
     * Class tomaintain a structure of field label and its value to be displayed on to the page.
    */
    public class KnowledgeArticleLabelValue{
        public String fieldLabel{get;set;}
        public String fieldValue{get;set;}

        /**
         * Constructor.
         */
        public KnowledgeArticleLabelValue(String pFieldLabel, String pFieldValue){
            fieldLabel = pFieldLabel;
            fieldValue = pFieldValue;
        }
    }

}
