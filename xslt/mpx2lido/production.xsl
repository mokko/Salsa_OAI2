<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
 xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

 <xsl:template name="production">
  <lido:eventSet>
   <xsl:call-template name="production-displayEvent"/>
   <lido:event>
    <lido:eventType>
     <lido:term>Production</lido:term>
    </lido:eventType>
    <lido:eventName>
     <lido:appellationValue xml:lang="de">Herstellung
     </lido:appellationValue>
    </lido:eventName>

    <!--
     TODO:
     -ensure that only cultures associated with Herstellung are named
     -to do so I need example data. At this point I am not sure there is any
    -->

    <!-- eventActor -->
    <xsl:apply-templates select="mpx:personKörperschaftRef[@funktion = 'Hersteller']"/>

    <!--culture -->
    <xsl:call-template name="general-culture"/>

    <!-- eventDate: both display and data -->
    <xsl:call-template name="eventDate"/>

    <!-- eventPlace -->
    <xsl:apply-templates
     select="mpx:geogrBezug [@funktion = 'Herkunft (Allgemein)' ] [not (@bezeichnung) or @bezeichnung != 'Ethnie' ][not (@bezeichnung) or @bezeichnung != 'Kultur' ]"/>

    <!--lido:eventMethod -->

    <!-- eventMaterialsTech -->
    <xsl:call-template name="eventMaterialsTech"/>
   </lido:event>
  </lido:eventSet>
 </xsl:template>


 <xsl:template name="production-displayEvent">
  <lido:displayEvent xml:lang="de">
   <xsl:text>Herstellung</xsl:text>
   <!--
    mpx:geogr[@funktion = 'Herkunft (Allgemein)' and (@bezeichnung !='Ethnie' or 
    @bezeichnung != 'Kultur')]
    what happens if there are several places?
    I puts there only the first place. Is there a XSLT-1-way to put all values in 
    one variable?
    eg:
    http://spk.mimo-project.eu:8080/oai?verb=GetRecord&metadataPrefix=lido&identifier=spk-berlin.de:EM-objId-255082

    The problem is that I cannot safely distinguish between one or several places. 
    Hence the displayPlace will
    always have some errors. So why don't we keep only the first place.

   -->

   <xsl:variable name="productionPlace">
    <xsl:if
     test="mpx:geogrBezug [
                    @funktion = 'Herkunft (Allgemein)' and  
                    @bezeichnung != 'Ethnie' and  
                    @bezeichnung != 'Kultur']">
     <xsl:value-of select="mpx:geogrBezug"/>
     <xsl:if test="mpx:geogrBezug/@bezeichnung">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="mpx:geogrBezug/@bezeichnung"/>
      <xsl:text>)</xsl:text>
     </xsl:if>
    </xsl:if>
   </xsl:variable>

   <xsl:if test="$productionPlace ">
    <xsl:text> am Ort </xsl:text>
    <xsl:value-of select="$productionPlace"/>
   </xsl:if>

   <xsl:if test="mpx:personKörperschaftRef[@funktion ='Hersteller' ]">
    <xsl:text> durch den/die Hersteller/Herstellerin </xsl:text>
    <xsl:value-of select="mpx:personKörperschaftRef[@funktion ='Hersteller' ]"/>
   </xsl:if>

   <xsl:variable name="culture"
    select="mpx:personKörperschaftRef[@funktion ='Ethnie' or @bezeichnung != 'Kultur' ]"/>
   <xsl:if test="$culture">
    <xsl:text> von der Ethnie/Kultur der </xsl:text>
    <xsl:value-of select="$culture"/>
   </xsl:if>

   <xsl:variable name="matTech" select="mpx:materialTechnik"/>
   <xsl:if test="mpx:materialTechnik">
    <xsl:text> unter Einsatz von </xsl:text>
    <xsl:value-of select="mpx:materialTechnik"/>
   </xsl:if>

   <!-- TODO
    can I deal with multiple datierung?
    do I show the datierung and only those or do I need to filter specific datierung?
   -->
   <xsl:if test="mpx:datierung">
    <xsl:text> zum Zeitpunkt bzw. im Zeitraum </xsl:text>
    <xsl:value-of select="mpx:datierung"/>
   </xsl:if>

  </lido:displayEvent>
 </xsl:template>


 <!-- EventActor -->
 <xsl:template match="mpx:personKörperschaftRef[@funktion = 'Hersteller']">
  <lido:eventActor>
   <lido:actorInRole>
    <xsl:call-template name="general-actor">
     <xsl:with-param name="kueId" select="@id"/>
    </xsl:call-template>
   </lido:actorInRole>
  </lido:eventActor>
 </xsl:template>


 <!-- EventPlace: Is this general? Might well be... -->
 <xsl:template match="mpx:geogrBezug">
  <lido:eventPlace>
   <lido:displayPlace>
    <xsl:value-of select="."/>
    <xsl:if test="@bezeichnung">
     <xsl:text> (</xsl:text>
     <xsl:value-of select="@bezeichnung"/>
     <xsl:text>)</xsl:text>
    </xsl:if>
   </lido:displayPlace>
   <lido:place>
    <lido:namePlaceSet>
     <!--
      I am pretty sure that geogrBezug should always be entered in German,
      I am less sure that it actually always is German, but that is a potential
      error on data entry level
     -->
     <lido:appellationValue xml:lang="de">
      <xsl:value-of select="."/>
     </lido:appellationValue>
    </lido:namePlaceSet>
   </lido:place>
  </lido:eventPlace>
 </xsl:template>


 <xsl:template name="eventMaterialsTech">
  <xsl:if test="mpx:materialTechnik">
   <!-- TODO: add a comma between different lines, but the last one -->
   <lido:eventMaterialsTech>
    <lido:displayMaterialsTech>
     <xsl:apply-templates select="mpx:materialTechnik" mode="display"/>
    </lido:displayMaterialsTech>
    <xsl:if
     test="mpx:materialTechnik/@art='Material' or mpx:materialTechnik/@art='Technik' ">
     <lido:materialsTech>
      <xsl:apply-templates select="mpx:materialTechnik"
       mode="data"/>
     </lido:materialsTech>
    </xsl:if>
   </lido:eventMaterialsTech>
  </xsl:if>
 </xsl:template>

 <xsl:template match="mpx:materialTechnik" mode="display">
  <xsl:value-of select="."/>
  <xsl:text> (</xsl:text>
  <xsl:value-of select="./@art"/>
  <xsl:text>)</xsl:text>
 </xsl:template>

 <!-- N.B. @art can also be 'Ausgabe -->
 <xsl:template match="mpx:materialTechnik" mode="data">
  <xsl:element name="lido:termMaterialsTech">
   <xsl:choose>
    <xsl:when test="@art = 'Material' ">
     <xsl:attribute name="lido:type">material</xsl:attribute>
    </xsl:when>
    <xsl:when test="@art = 'Technik' ">
     <xsl:attribute name="lido:type">technique</xsl:attribute>
    </xsl:when>
   </xsl:choose>
   <lido:term xml:lang="de">
    <xsl:value-of select="."/>
   </lido:term>
  </xsl:element>
 </xsl:template>


 <!--
  eventDate: should this become a general? it is not used in acquisition. At the 
  moment
  it is not used in collecting either.
  TODO: Probably only applies if Herkunft Allgemein
  TODO: datierung is repeatable
 -->

 <xsl:template name="eventDate">
  <lido:eventDate>
   <!-- displayDate geht immer, auch unstructuredText -->
   <xsl:for-each select="mpx:datierung">
    <lido:displayDate>
     <xsl:value-of select="."/>
    </lido:displayDate>
   </xsl:for-each>
   <!--
    TODO:
    Test if date is really a proper date and not freetext
    The dates format should be preferably YYYY[-MM[-DD]]:
    at least the year should be specified. Nevertheless, other
    formats are accepted (e.g 17??, 1850 ?, ca 1600, etc…).

    can I deal with multiple datierung?
    do I show the datierung and only those or do I need to filter specific datierung?
    @vonJahr und @bisJahr
    How to recognize earliest and latestDate?
    Maybe work only only with 4-digit years:
    <xsl:if test=". = format-number(.,'####')">

    <lido:date>
    <lido:earliestDate><xsl:value-of select="mpx:datierung"/></lido:earliestDate>
    <lido:latestDate><xsl:value-of select="mpx:datierung"/></lido:latestDate>
    </lido:date>
    </xsl:if>
   -->
  </lido:eventDate>
 </xsl:template>

</xsl:stylesheet>
