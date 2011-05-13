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
                    <lido:legalBodyID lido:type="local">SPK</lido:legalBodyID>
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
    <!-- 
        resourceSet 
        - MIMO wants a resourceSet only for resources which have an URL
        - MIMO generates image URL from resourceID
        - additional URLs for the same resource can be supplied in linkResource; only publically available URLs

        Questions
        -How do I identify mpx:multimediaobjekt records which have an image?
        currently: if local path exists
        future: mpx2lido uses @freigabe="web" and a script determines the freigabe status and writes it in mpx.
        @freigabe="web" 
        write a freigabe script that determines if image is available and possibly checks other
        conditions 
    -->
    <xsl:template
        match="/mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt and mpx:multimediaPfadangabe]">
        <!--  $currentId -->

        <lido:resourceSet>
            <!--
                we need a media server before we can deliver the url, in the meantime we can put the local URI
                in the meantime MIMO has set up an ftp server and we just need to upload stuff
                
            -->
            <lido:resourceID lido:pref="preferred" lido:type="local">
                <xsl:value-of select="@mulId"/>
                <xsl:text>.jpg</xsl:text>
            </lido:resourceID>
            <!--
                write a resourceRepresentation only if there is a URL (not an internal filepath)
            -->
            <xsl:if test="contains (mpx:multimediaPfadangabe, '://')">
                <lido:resourceRepresentation>
                    <lido:linkResource>
                        <xsl:value-of
                            select="concat(mpx:multimediaPfadangabe,'/',mpx:multimediaDateiname,'.',mpx:multimediaErweiterung)"
                        />
                    </lido:linkResource>
                    <!-- 
                    internal MuseumPlus paths 
                    <xsl:value-of
                    select="concat(mpx:multimediaPfadangabe,'\',mpx:multimediaDateiname,'.',mpx:multimediaErweiterung)"
                    />
                -->
                </lido:resourceRepresentation>
            </xsl:if>

            <lido:resourceType>
                <lido:term xml:lang="en">image</lido:term>
            </lido:resourceType>
            <lido:rightsResource>
                <lido:rightsType>
                    <lido:term xml:lang="en">copyright</lido:term>
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
