<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="mpx" version="2.0"
	xmlns:mpx="http://www.mpx.org/mpx" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- 
	DF: a mume doublette is the case where more than one mume records describe the same file (image) 
	redundantly.
	
	Occasionally, the same image is supposed to be used for two different objects, such as a drum and its
	mallet. So this case is not a doublette. 
	
	I am thinking about filtering out mume records for cases where one sammlungsobjekt has several
	(usually: near identical) mume records which point to the same file (image). Possibly only those cases 
	where one is an old fake mume and the other is a new exported mume.
	
	The question is which record has better information. According to my normal join-rule, I should keep
	the newer mume record.
	
	The risk here is to discard a mume record with a working path and keep a mume record with a non-working
	path, i.e. effectively losing images
	
	Currently this transform messages out information on those mume records, rather than eliminating them.	
	
	-->

	<xsl:output method="xml" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:strip-space elements="*" />


	<xsl:template match="/">
		<xsl:for-each-group
			select="mpx:museumPlusExport/mpx:multimediaobjekt[@freigabe eq 'Web']"
			group-by="mpx:verknüpftesObjekt">
			<xsl:for-each-group select="current-group()"
				group-by="mpx:multimediaDateiname">

				<xsl:if test="count(current-group()) > 1">
					<xsl:for-each select="current-group()">
						<xsl:if test="@quelle">
							<xsl:message>
								<xsl:value-of
									select="@mulId,mpx:verknüpftesObjekt, mpx:multimediaDateiname" />
							</xsl:message>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each-group>
		</xsl:for-each-group>

	</xsl:template>
</xsl:stylesheet>
