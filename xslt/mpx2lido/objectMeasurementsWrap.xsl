<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:lido="http://www.lido-schema.org"
  xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

  <xsl:template name="objectMeasurementsWrap">
    <xsl:if test="child::mpx:maßangabe">
      <lido:objectMeasurementsWrap>
        <xsl:apply-templates select="child::mpx:maßangabe" />
      </lido:objectMeasurementsWrap>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mpx:maßangabe">
    <lido:objectMeasurementsSet>
      <lido:displayObjectMeasurements>
        <xsl:if test="@typ">
          <xsl:value-of xml:space="preserve" select="@typ" />
          <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:value-of xml:space="preserve" select="." />
      </lido:displayObjectMeasurements>

      <xsl:if test="@typ = 'Objektmaß'">
        <!--
          xpath 1 is somewhat limited: split at space; take 1st, 3rd & 5th as
          values; 6th as unit. There may be strings following which should be
          ignored.
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

        <lido:objectMeasurements>
          <xsl:element name="lido:measurementsSet">
            <xsl:attribute name="lido:type">Höhe</xsl:attribute>
            <xsl:attribute name="lido:unit">
              <xsl:value-of select="$unit" />
            </xsl:attribute>
            <xsl:attribute name="lido:value">
              <xsl:value-of select="$value1" />
            </xsl:attribute>
          </xsl:element>
          <xsl:element name="lido:measurementsSet">
            <xsl:attribute name="lido:type">Breite</xsl:attribute>
            <xsl:attribute name="lido:unit">
              <xsl:value-of select="$unit" />
            </xsl:attribute>
            <xsl:attribute name="lido:value">
              <xsl:value-of select="$value2" />
            </xsl:attribute>
          </xsl:element>
          <xsl:element name="lido:measurementsSet">
            <xsl:attribute name="lido:type">Tiefe</xsl:attribute>
            <xsl:attribute name="lido:unit">
              <xsl:value-of select="$unit" />
            </xsl:attribute>
            <xsl:attribute name="lido:value">
              <xsl:value-of select="$value3" />
            </xsl:attribute>
          </xsl:element>
        </lido:objectMeasurements>
      </xsl:if>
    </lido:objectMeasurementsSet>
  </xsl:template>

</xsl:stylesheet>
