<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

    <xsl:template name="administrativeMetadata">

        <lido:administrativeMetadata xml:lang="de">
            <lido:rightsWorkWrap>
                <lido:rightsWorkSet>
                    <lido:rightsType>
                        <lido:term xml:lang="de">copyright</lido:term>
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
                    <lido:legalBodyName>
                        <lido:appellationValue xml:lang="de">
                            <xsl:value-of select="child::mpx:verwaltendeInstitution"/>
                        </lido:appellationValue>
                    </lido:legalBodyName>
                </lido:recordSource>
            </lido:recordWrap>
            <!-- resourceWrap -->
            <xsl:if test="/mpx:museumPlusExport/mpx:multimediaobjekt">
                <lido:resourceWrap>
                    <xsl:apply-templates
                        select="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt]"/>
                </lido:resourceWrap>
            </xsl:if>
        </lido:administrativeMetadata>
    </xsl:template>

    <!-- resourceWrap -->
    <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt]">
        <!--  $currentId -->

        <lido:resourceSet>
            <!--
                we need a media server before we can deliver the url, in the meantime we can put the local URI
                in the meantime MIMO has set up an ftp server and we just need to upload stuff
                
            -->
            <lido:resourceID lido:pref="preferred" lido:type="local">
                <xsl:value-of select="@mulId"/>
            </lido:resourceID>
            <!--
                at this time I don't know how to differenciate between image resources and others, probably there is a mume field
                xml:lang="en" not supported in resourceType in LIDO 0.9, but specified in example from Paris
                http://194.250.19.133/scripts/oaiserver_lido.asp?verb=getrecord&set=MU&metadataprefix=lido&identifier=0156624
            -->
            <lido:resourceRepresentation>
                <lido:linkResource>

                    <!-- match urls -->
                    <xsl:choose>
                        <xsl:when test="contains (mpx:multimediaPfadangabe, '://')">
                            <xsl:value-of
                                select="concat(mpx:multimediaPfadangabe,'/',mpx:multimediaDateiname,'.',mpx:multimediaErweiterung)"
                            />
                        </xsl:when>

                        <!-- match internal MuseumPlus paths -->
                        <xsl:otherwise>
                            <xsl:value-of
                                select="concat(mpx:multimediaPfadangabe,'\',mpx:multimediaDateiname,'.',mpx:multimediaErweiterung)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </lido:linkResource>
            </lido:resourceRepresentation>

            <lido:resourceType>
                <lido:term xml:lang="en">image</lido:term>
            </lido:resourceType>
            <lido:rightsResource>
                <lido:rightsType>
                    <lido:term>copyright</lido:term>
                </lido:rightsType>
            </lido:rightsResource>
            <lido:rightsResource>
                <lido:creditLine>
                    <xsl:value-of select="mpx:multimediaUrhebFotograf"/>
                </lido:creditLine>
            </lido:rightsResource>
        </lido:resourceSet>
    </xsl:template>

</xsl:stylesheet>
