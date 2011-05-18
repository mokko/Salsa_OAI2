<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">
    
    <xsl:import href="resourceSet.xsl"/>
    
    <xsl:template name="administrativeMetadata">
        <lido:administrativeMetadata xml:lang="de">
            <lido:rightsWorkWrap>
                <lido:rightsWorkSet>
                    <lido:rightsType>
                        <lido:term xml:lang="en">copyright</lido:term>
                    </lido:rightsType>
                    <lido:rightsHolder>
                        <lido:legalBodyName>
                            <lido:appellationValue xml:lang="de">
                                <xsl:value-of select="child::mpx:credits"/>
                            </lido:appellationValue>
                        </lido:legalBodyName>
                    </lido:rightsHolder>
                </lido:rightsWorkSet>
            </lido:rightsWorkWrap>
            <lido:recordWrap>
                <lido:recordID lido:type="local">
                    <xsl:value-of select="@objId"/>
                </lido:recordID>

                <lido:recordType>
                    <lido:term>item</lido:term>
                </lido:recordType>

                <lido:recordSource>
                    <lido:legalBodyID lido:type="local">SPK</lido:legalBodyID>
                    <lido:legalBodyName>
                        <lido:appellationValue xml:lang="de">
                            <xsl:value-of select="child::mpx:verwaltendeInstitution"/>
                        </lido:appellationValue>
                    </lido:legalBodyName>
                </lido:recordSource>
            </lido:recordWrap>
            <!-- resourceWrap -->
            <xsl:if test="/mpx:museumPlusExport/mpx:multimediaobjekt[ @freigabe = 'web' ]">
                <lido:resourceWrap>
                    <xsl:apply-templates
                        select="/mpx:museumPlusExport/mpx:multimediaobjekt[ @freigabe = 'web' ]"/>
                </lido:resourceWrap>
            </xsl:if>
        </lido:administrativeMetadata>
    </xsl:template>
</xsl:stylesheet>
