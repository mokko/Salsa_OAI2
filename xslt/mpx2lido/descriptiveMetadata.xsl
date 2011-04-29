<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">
    
    <xsl:template match="child::mpx:titel">
        <lido:classification>
            <lido:term xml:lang="de">
                <xsl:value-of select="."/>
            </lido:term>
        </lido:classification>
    </xsl:template>
    
    <xsl:template match="child::mpx:sachbegriff">
        <lido:classification>
            <lido:term xml:lang="de">
                <xsl:value-of select="."/>
            </lido:term>
        </lido:classification>
    </xsl:template>
    
    <xsl:template name="descriptiveMetadata">
        <lido:descriptiveMetadata xml:lang="de">
            <lido:objectClassificationWrap>
                <lido:objectWorkTypeWrap>
                    <lido:objectWorkType>
                        <lido:term><xsl:value-of select="child::mpx:objekttyp"/></lido:term>
                    </lido:objectWorkType>
                </lido:objectWorkTypeWrap>

                <xsl:if
                    test="child::mpx:titel or child::mpx:sachbegriff or child::mpx:systematikArt">
                    <lido:classificationWrap>
                        <xsl:apply-templates select="child::mpx:titel"/>
                        <xsl:apply-templates select="child::mpx:sachbegriff"/>
                        <xsl:apply-templates select="child::mpx:titel"/>
                        <xsl:if test="child::mpx:systematikArt">
                            <lido:classification>
                                <lido:term xml:lang="de">
                                    <xsl:value-of select="."/>
                                </lido:term>
                            </lido:classification>
                        </xsl:if>
                    </lido:classificationWrap>
                </xsl:if>
            </lido:objectClassificationWrap>
            <lido:objectIdentificationWrap>
                <!--
                    Should we involve sachbegriff and titel ? I guess so, but how exactly
                    According to lido-v0.7.xsd titleSet is repeatable, MIMO D2.1 is contradicting itself
                    TODO: Currently, I put all mpx:sachbegriff and mpx:titel. Probably not good.
                -->
                <!--xsl:value-of select="'DEBUG:mpx:sachbegriff exists'"/-->
                <lido:titleWrap>

                    <xsl:choose>
                        <xsl:when test="child::mpx:titel" xml:space="preserve">
                            <xsl:for-each select="child::mpx:titel">
                                <lido:titleSet>
                                    <lido:appellationValue><xsl:value-of select="."/></lido:appellationValue>
                                </lido:titleSet>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="child::mpx:sachbegriff">
                            <xsl:for-each select="child::mpx:sachbegriff" xml:space="preserve">
                                <lido:titleSet>
                                    <lido:appellationValue><xsl:value-of select="."/></lido:appellationValue>
                                </lido:titleSet>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- otherwise: If neither mpx:titel or mpx:sachbegriff, write nothing & create a non-validating lido so we can find the error easily-->
                            <lido:titleSet>
                                <lido:appellationValue> kein Titel </lido:appellationValue>
                            </lido:titleSet>
                        </xsl:otherwise>
                    </xsl:choose>
                </lido:titleWrap>
                <lido:repositoryWrap>
                    <lido:repositorySet lido:type="current">
                        <lido:repositoryName>
                            <lido:legalBodyName>
                                <lido:appellationValue>
                                    <!-- Soll hier mpx:credit verwendet werden? -->
                                    <xsl:value-of select="child::mpx:verwaltendeInstitution"/>
                                </lido:appellationValue>
                            </lido:legalBodyName>
                        </lido:repositoryName>
                        <lido:workID lido:type="inventory number">
                            <xsl:value-of select="child::mpx:identNr"/>
                        </lido:workID>
                        <!-- was tun mit mehrfachen identNr und alten Nr?-->
                    </lido:repositorySet>
                </lido:repositoryWrap>
            </lido:objectIdentificationWrap>
        </lido:descriptiveMetadata>
    </xsl:template>



</xsl:stylesheet>
