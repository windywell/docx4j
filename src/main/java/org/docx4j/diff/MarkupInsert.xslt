<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dfx="http://www.topologi.org/2004/Diff-X"
  xmlns:del="http://www.topologi.org/2004/Diff-X/Delete"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"      
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:WX="http://schemas.microsoft.com/office/word/2003/auxHint"
  xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
        xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns:ext="http://www.xmllab.net/wordml2html/ext"
  xmlns:java="http://xml.apache.org/xalan/java"
  xmlns:xml="http://www.w3.org/XML/1998/namespace"
  version="1.0"
        exclude-result-prefixes="java msxsl ext o v WX aml w10">

  <!-- 
  *  Copyright 2007, Plutext Pty Ltd.
  *
  *  This file is part of plutext-client-word2007.

  plutext-client-word2007 is free software: you can redistribute it and/or
  modify it under the terms of version 3 of the GNU General Public License
  as published by the Free Software Foundation.

  plutext-client-word2007 is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with plutext-client-word2007.  If not, see
  <http://www.gnu.org/licenses/>.

  -->

<xsl:param name="ParagraphDifferencer"/>
<xsl:param name="author"/>
<xsl:param name="date"/>
<xsl:param name="docPartRelsLeft"/>
<xsl:param name="docPartRelsRight"/>

<xsl:preserve-space elements="w:t"/> 


  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

  <xsl:template match="/ | @*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="w:r">
  
            <xsl:variable name="id" 
                select="java:org.docx4j.diff.ParagraphDifferencer.getId()" />
  

    <w:ins w:id="{$id}" w:author="{$author}"  w:date="{$date}">  <!--  w:date is optional -->
        <xsl:apply-templates/>
    </w:ins>
    
  </xsl:template>
  
  <xsl:template match="w:t">

       <xsl:apply-templates/>

  </xsl:template>

  <!-- Handle  <w:sym w:font="Wingdings" w:char="F04A" /> -->
  <xsl:template match="w:sym">
    <w:r>
      <xsl:apply-templates select="../../w:rPr" mode="omitDeletions"/>
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </w:r>
  </xsl:template>

  <!--  w:drawing: there are 3 cases:
  
        (1) drawing deleted (ie present in RHS only)  NOT RELEVANT TO MarkupInsert      
        (2) drawing, inserted in LHS
        
        (3) normal drawing, present in LHS & RHS
  
    -->
    
<xsl:template match="w:drawing" priority="5">
  
  	<xsl:choose>
  		<xsl:when test="@dfx:delete='true'"> <!--  NOT RELEVANT TO MarkupInsert -->
			<xsl:variable name="id" 
						select="java:org.docx4j.diff.ParagraphDifferencer.getId()" />
		    <w:del w:id="{$id}" w:author="{$author}" w:date="{$date}">  <!--  w:date is optional -->
		      <w:r>
			      <xsl:copy>
			        <xsl:apply-templates select="node()"/> <!--  drop @ -->
			      </xsl:copy>
		      </w:r>
		    </w:del>    		
  		</xsl:when>
  		<xsl:when test="@dfx:insert='true'">
			<xsl:variable name="id" 
						select="java:org.docx4j.diff.ParagraphDifferencer.getId()" />
		    <w:ins w:id="{$id}" w:author="{$author}" w:date="{$date}">  <!--  w:date is optional -->
		      <w:r>
			      <xsl:copy>
			        <xsl:apply-templates select="node()"/> <!--  drop @ -->
			      </xsl:copy>
		      </w:r>
		    </w:ins>    		  		
  		</xsl:when>
  		<xsl:otherwise>
		      <w:r>
			      <xsl:copy>
			        <xsl:apply-templates select="node()"/> <!--  drop @, though there shouldn't be any -->
			      </xsl:copy>
		      </w:r>
  		</xsl:otherwise>
	</xsl:choose>  		
  
  </xsl:template>
      
    
    <xsl:template match="a:blip"  priority="5">
    
    	<xsl:choose>
		    <!--  case (1) drawing deleted (ie present in RHS only) 
		          IRRELEVANT HERE       -->
    		<xsl:when test="@dfx:delete='true'">
    			<!--  Handle link|embed -->
    			<xsl:choose>
    				<xsl:when test="count(@del:link)=1">
    					<xsl:variable name="oldid" select="string(@del:link)" />
    					<xsl:variable name="newid" select="concat($oldid, 'R')" /> <!--  From RIGHT rels -->
    					<xsl:variable name="dummy" 
    					     select="java:org.docx4j.diff.ParagraphDifferencer.registerRelationship(
    					     	$ParagraphDifferencer, $docPartRelsRight, $oldid, $newid)" />
    					<a:blip r:link="{$newid}" />
    				</xsl:when>
    				<xsl:otherwise> <!--  r:embed -->
    					<xsl:variable name="oldid" select="string(@del:embed)" />
    					<xsl:variable name="newid" select="concat($oldid, 'R')" /> <!--  From RIGHT rels -->
    					<xsl:variable name="dummy" 
    					     select="java:org.docx4j.diff.ParagraphDifferencer.registerRelationship(
    					     	$ParagraphDifferencer, $docPartRelsRight, $oldid, $newid)" />
    					<a:blip r:embed="{$newid}" />    				
    				</xsl:otherwise>
    			</xsl:choose>    		
    		</xsl:when>
		  <!--  cases:
		        (2) drawing, inserted in LHS
		        (3) normal drawing, present in LHS & RHS  
		    -->
			<xsl:otherwise>
    			<!--  Handle link|embed -->
    			<xsl:choose>
    				<xsl:when test="count(@r:link)=1">
    					<xsl:variable name="oldid" select="string(@r:link)" />
    					<xsl:variable name="newid" select="concat($oldid, 'L')" /> <!--  LEFT -->
    					<xsl:variable name="dummy" 
    					     select="java:org.docx4j.diff.ParagraphDifferencer.registerRelationship(
    					     	$ParagraphDifferencer, $docPartRelsLeft, $oldid, $newid)" />
    					<a:blip r:link="{$newid}" />
    				</xsl:when>
    				<xsl:otherwise> <!--  r:embed -->
    					<xsl:variable name="oldid" select="string(@r:embed)" />
    					<xsl:variable name="newid" select="concat($oldid, 'L')" /> <!--  LEFT -->
    					<xsl:variable name="dummy" 
    					     select="java:org.docx4j.diff.ParagraphDifferencer.registerRelationship(
    					     	$ParagraphDifferencer, $docPartRelsLeft, $oldid, $newid)" />
    					<a:blip r:embed="{$newid}" />    				
    				</xsl:otherwise>
    			</xsl:choose>    					
			</xsl:otherwise>
		</xsl:choose>    
    
    </xsl:template>

	<!--  Recover deleted drawing; not relevant to MarkupInsert. 
		
			<xsl:template match="@dfx:delete[ancestor::w:drawing]" />
		    
			<xsl:template match="@del:*[ancestor::w:drawing]" >
				<xsl:attribute name="{local-name(.)}">
					<xsl:value-of select="." />
				</xsl:attribute>	
			</xsl:template>
	-->
    
	<!--  Fix inserted drawing? No, nothing to do here, since @dfx:insert="true"
	      is removed above.   
	
		<w:r dfx:insert="true"><w:rPr dfx:insert="true"><w:noProof dfx:insert="true" />
		    </w:rPr>
		    <w:drawing dfx:insert="true">
		        <wp:inline dfx:insert="true">
		            <wp:extent dfx:insert="true" cx="457200" cy="400050" />
	
	-->


  <!--  w:hyperlink            @r:id  
  
	  <w:hyperlink dfx:insert="true" r:id="rId5" w:history="true">
	  	<w:r>
	  		<w:rPr dfx:insert="true"><w:rStyle dfx:insert="true" w:val="Hyperlink" /></w:rPr>
	  		<w:t>
	  			<ins>http://slashdot.org</ins>
	  			<del>3</del>
	  		</w:t>
	  	</w:r>
	  </w:hyperlink>
	  
	  Word 2007 tracks the insertion/deletion of hyperlinks using 
	  w:ins and w:del around the corresponding fields.
	  
	  We could replicate that, I guess.
	  
	  But for now, *we don't track the hyperlink itself*; just the text inside it. 
	  	    
  
  -->
  <xsl:template match="w:hyperlink" priority="5">
  
  	<xsl:choose>
  		<xsl:when test="@dfx:delete='true'">
			<xsl:variable name="id" 
						select="java:org.docx4j.diff.ParagraphDifferencer.getId()" />
		    
				<xsl:variable name="oldid" select="string(@del:id)" />
				<xsl:variable name="newid" select="concat($oldid, 'R')" /> <!--  From RIGHT rels -->
				<xsl:variable name="dummy" 
				     select="java:org.docx4j.diff.ParagraphDifferencer.registerRelationship(
				     	$ParagraphDifferencer, $docPartRelsRight, $oldid, $newid)" />
				<w:hyperlink r:id="{$newid}">
			    	<xsl:apply-templates select="@*|node()"/>
				</w:hyperlink>
  		</xsl:when>
  		<xsl:when test="@dfx:insert='true'">
			<xsl:variable name="id" 
						select="java:org.docx4j.diff.ParagraphDifferencer.getId()" />
				<xsl:variable name="oldid" select="string(@r:id)" />
				<xsl:variable name="newid" select="concat($oldid, 'L')" /> <!--  LEFT -->
				<xsl:variable name="dummy" 
				     select="java:org.docx4j.diff.ParagraphDifferencer.registerRelationship(
				     	$ParagraphDifferencer, $docPartRelsLeft, $oldid, $newid)" />
				<w:hyperlink r:id="{$newid}">
			    	<xsl:apply-templates select="@*|node()"/>
				</w:hyperlink>
  		</xsl:when>
  		<xsl:otherwise>
				<xsl:variable name="oldid" select="string(@r:id)" />
				<xsl:variable name="newid" select="concat($oldid, 'L')" /> <!--  LEFT -->
				<xsl:variable name="dummy" 
				     select="java:org.docx4j.diff.ParagraphDifferencer.registerRelationship(
				     	$ParagraphDifferencer, $docPartRelsLeft, $oldid, $newid)" />
				<w:hyperlink r:id="{$newid}">
			    	<xsl:apply-templates select="@*|node()"/>
				</w:hyperlink>
  		</xsl:otherwise>
	</xsl:choose>  		
  
  </xsl:template>

  <!--  
    TODO        
        w:object/v:imagedata
        
        w:object/o:OLEObject  
    
  -->

  <!--  comments, footnotes, endnotes are simply stripped.
        Handling these properly requires composing new parts,
        for which an extension function similar to
        registerRelationship would be required.
        
        Quite feasible, but a TODO. -->
  <xsl:template match="w:commentReference | w:commentRangeStart | w:commentRangeEnd" />

  <xsl:template match="w:footnoteReference | w:endnoteReference" />



  <xsl:template match="w:tab[parent::w:r]"> <!-- so we don't match tab in properties -->

    <w:r>
      <xsl:apply-templates select="../w:rPr" />
      <w:tab/> 
    </w:r>

  </xsl:template>


  <xsl:template match="text()">
  
      <w:r>
   		<xsl:apply-templates select="../../w:rPr"/>
        <w:t xml:space="preserve"><xsl:value-of select="."/></w:t>
      </w:r>
    
  </xsl:template>
  

</xsl:stylesheet>
