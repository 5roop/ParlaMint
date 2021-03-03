<?xml version="1.0"?>
<!-- Take template for root ParlaMint corpus file and add info from XIncluded roots -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  exclude-result-prefixes="#all"
  version="2.0">

  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <!-- We need "../" as the this XSLT is in Scripts! -->
      <item>
	<xsl:value-of select="concat('../', @href)"/>
      </item>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="tei:titleStmt/tei:respStmt[last()]">
    <xsl:copy-of select="."/>
    <xsl:for-each select="$docs//tei:item">
      <xsl:for-each select="document(.)/tei:teiCorpus">
	<xsl:variable name="corpus" select="@xml:id"/>
	<xsl:for-each select="tei:teiHeader//tei:titleStmt/tei:respStmt">
	  <xsl:copy>
	    <xsl:for-each select="tei:persName[not(contains(@xml:lang, 'Cyr'))]">
	      <xsl:copy>
		<xsl:value-of select="."/>
	      </xsl:copy>
	    </xsl:for-each>
	    <xsl:for-each select="tei:resp[@xml:lang='en']">
	      <xsl:copy>
		<xsl:value-of select="concat($corpus, ': ', .)"/>
	      </xsl:copy>
	    </xsl:for-each>
	  </xsl:copy>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="when" select="$today"/>
      <xsl:value-of select="format-date(current-date(), '[MNn] [D], [Y]')"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="tei:extent">
    <xsl:copy>
      <xsl:variable name="corpora" select="count($docs/tei:item)"/>
      <measure unit="corpora" quantity="{format-number($corpora, '#')}">
	<xsl:value-of select="concat(format-number($corpora, '###,###,###'), ' corpora')"/>
      </measure>
      <xsl:variable name="quant">
	<xsl:variable name="quants">
	  <xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus">
	    <item>
	      <xsl:value-of select="count(xi:include)"/>
	    </item>
	  </xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="sum($quants/tei:item)"/>
      </xsl:variable>
      <measure unit="texts" quantity="{format-number($quant, '#')}">
	<xsl:value-of select="concat(format-number($quant, '###,###,###'), ' texts')"/>
      </measure>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:extent/tei:measure">
    <xsl:variable name="unit" select="@unit"/>
    <xsl:variable name="quant">
      <xsl:variable name="quants">
	<xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus/tei:teiHeader//
			      tei:extent/tei:measure[@xml:lang='en'][@unit = $unit]">
	  <item>
	    <xsl:value-of select="@quantity"/>
	  </item>
	</xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="sum($quants/tei:item)"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:attribute name="unit" select="$unit"/>
      <xsl:attribute name="quantity" select="format-number($quant, '#')"/>
      <xsl:value-of select="concat(format-number($quant, '###,###,###'), ' ', $unit)"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tei:tagUsage">
    <xsl:variable name="tagUsages">
      <xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus/tei:teiHeader//
			    tei:tagsDecl//tei:tagUsage">
	<xsl:sort select="@gi"/>
	<xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each select="$tagUsages/tei:tagUsage">
      <xsl:variable name="gi" select="@gi"/>
      <xsl:if test="not(following-sibling::tei:tagUsage[@gi = $gi])">
	<xsl:variable name="occurences">
	  <xsl:for-each select="$tagUsages/tei:tagUsage[@gi = $gi]">
	    <item>
	      <xsl:value-of select="@occurs"/>
	    </item>
	  </xsl:for-each>
	</xsl:variable>
        <tagUsage gi="{$gi}" occurs="{format-number(sum($occurences/tei:item), '#')}"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="tei:sourceDesc/tei:bibl">
    <xsl:for-each select="$docs/tei:item/document(.)/tei:teiCorpus">
      <xsl:sort select="@xml:id"/>
      <listBibl>
	<head>
	  <xsl:value-of select="@xml:id"/>
	</head>
	<xsl:for-each select="tei:teiHeader//tei:sourceDesc/tei:bibl">
	  <!-- We just want the original sources, not ParlaMint ones -->
	  <xsl:if test="not(contains(., 'ParlaMint'))">
	    <bibl>
	      <xsl:apply-templates select="tei:*[not(@xml:lang) or @xml:lang = 'en']"/>
	    </bibl>
	  </xsl:if>
	</xsl:for-each>
      </listBibl>
    </xsl:for-each>
  </xsl:template>
    
  <xsl:template match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <change when="{$today}"><name>Tomaž Erjavec</name>: First try.</change>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(name() = 'xml:lang')]"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
