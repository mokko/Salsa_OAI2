<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:lido="http://www.lido-schema.org"
    xmlns:mpx="http://www.mpx.org/mpx" exclude-result-prefixes="mpx">

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
        /mpx:museumPlusExport/mpx:multimediaobjekt[mpx:verknüpftesObjekt and @freigabe='web']
    -->
    <xsl:template match="/mpx:museumPlusExport/mpx:multimediaobjekt[ @freigabe = 'web' ]">
        <!--  $currentId -->
            <lido:resourceSet>
                <xsl:element name="lido:resourceID">
                    <xsl:if test="@priorität = 1">
                        <xsl:attribute name="lido:pref">preferred</xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="lido:type">local</xsl:attribute>
                    <xsl:value-of select="@mulId"/>
                    <xsl:text>.jpg</xsl:text>
                </xsl:element>
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
                    <!-- TODO: different media according to which criteria? -->
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
