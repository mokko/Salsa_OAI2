<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
  xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

  <xsl:template name="objectMeasurementsWrap">
    <xsl:if test="mpx:maßangabe">
      <lido:objectMeasurementsWrap>
        <xsl:apply-templates select="mpx:maßangabe"/>
      </lido:objectMeasurementsWrap>
    </xsl:if>
  </xsl:template>


  <xsl:template match="mpx:maßangabe">
    <lido:objectMeasurementsSet>
      <lido:displayObjectMeasurements xml:lang="de" lido:encodinganalog="mpx:maßangabe">
        <xsl:if test="@typ">
          <xsl:value-of xml:space="preserve" select="@typ"/>
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:value-of xml:space="preserve" select="."/>
      </lido:displayObjectMeasurements>


      <xsl:if
        test="
        @typ = 'Durchmesser' or 
        @typ = 'Höhe' or 
        @typ = 'Länge' or
        @typ = 'Objektmaß' 
        ">
        <lido:objectMeasurements>
          <xsl:if test="@typ = 'Durchmesser' or @typ = 'Höhe' or @typ = 'Länge' ">
            <xsl:call-template name="DurchmesserHöheLänge"/>
          </xsl:if>
          <xsl:if test="@typ = 'Objektmaß' ">
            <xsl:call-template name="Objektmaß"/>
          </xsl:if>
        </lido:objectMeasurements>
      </xsl:if>
    </lido:objectMeasurementsSet>
  </xsl:template>



  <!-- unit is limited to 2 or less characters! -->
  <xsl:template name="DurchmesserHöheLänge">
    <xsl:variable name="value" select="substring-before(.,' ')"/>
    <xsl:variable name="rest" select="substring-after(.,' ')"/>
    <xsl:variable name="unit" select="substring ($rest, 1,2)"/>

    <xsl:element name="lido:measurementsSet">
      <xsl:element name="lido:measurementType" xml:lang="en">
        <xsl:choose>
          <xsl:when test="@typ = 'Durchmesser'">
            <xsl:text>diameter</xsl:text>
          </xsl:when>
          <xsl:when test="@typ = 'Höhe'">
            <xsl:text>height</xsl:text>
          </xsl:when>
          <xsl:when test="@typ = 'Länge'">
            <xsl:text>length</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="lido:measurementUnit">
        <xsl:value-of select="$unit"/>
      </xsl:element>
      <xsl:element name="lido:measurementValue">
        <xsl:value-of select="translate($value,',','.')"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>


  <xsl:template name="Objektmaß">
    <!--
    xpath 1 is somewhat limited: split at space; take 1st, 3rd & 5th as
    values; 6th as unit. There may be strings following which should be
    ignored. This works only for units abbreviated with 2 or less
    letters!
  -->
    <xsl:variable name="value1" select="substring-before(.,' ')"/>
    <xsl:variable name="rest" select="substring-after(.,' ')"/>
    <xsl:variable name="rest1" select="substring-after($rest,' ')"/>
    <xsl:variable name="value2" select="substring-before($rest1,' ')"/>
    <xsl:variable name="rest2" select="substring-after($rest1,' ')"/>
    <xsl:variable name="rest3" select="substring-after($rest2,' ')"/>
    <xsl:variable name="value3" select="substring-before($rest3,' ')"/>
    <xsl:variable name="rest4" select="substring-after($rest3,' ')"/>
    <xsl:variable name="unit" select="substring ($rest4, 1,2)"/>

    <xsl:element name="lido:measurementsSet">
      <xsl:element name="lido:measurementType" xml:lang="en">height</xsl:element>
      <xsl:element name="lido:measurementUnit">
        <xsl:value-of select="$unit"/>
      </xsl:element>
      <xsl:element name="lido:measurementValue">
        <xsl:value-of select="translate($value1,',','.')"/>
      </xsl:element>
    </xsl:element>

    <xsl:element name="lido:measurementsSet">
      <xsl:element name="lido:measurementType" xml:lang="en">width</xsl:element>
      <xsl:element name="lido:measurementUnit">
        <xsl:value-of select="$unit"/>
      </xsl:element>
      <xsl:element name="lido:measurementValue">
        <xsl:value-of select="translate($value2,',','.')"/>
      </xsl:element>
    </xsl:element>

    <xsl:element name="lido:measurementsSet">
      <xsl:element name="lido:measurementType" xml:lang="en">depth</xsl:element>
      <xsl:element name="lido:measurementUnit">
        <xsl:value-of select="$unit"/>
      </xsl:element>
      <xsl:element name="lido:measurementValue">
        <xsl:value-of select="translate($value3,',','.')"/>
      </xsl:element>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
