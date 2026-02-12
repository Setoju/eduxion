export default class BookService {
  constructor(wordsPerPage = 200) {
    this.wordsPerPage = wordsPerPage
  }

  getPages(element) {
    const textContent = element.textContent.trim()
    const innerHTML = element.innerHTML.trim()
    
    // Process markdown if the content appears to use markdown syntax
    if (this.containsMarkdown(textContent)) {
      const html = this.processMarkdown(textContent)
      return this.paginateHTML(html)
    } else if (innerHTML.includes('<')) {
      // Use HTML content if it's already formatted
      return this.paginateHTML(innerHTML)
    } else {
      // Simple text splitting
      return this.paginateText(textContent)
    }
  }

  containsMarkdown(text) {
    const markdownPatterns = [
      /\n\n/,
      /^#{1,6}\s+/m,
      /\*\*.*?\*\*/,
      /\*.*?\*/,
      /`.*?`/,
      /^\*\s+/m,
      /^\d+\.\s+/m,
      /^\>\s+/m,
      /!\[.*?\]\(.*?\)/,
      /\[.*?\]\(.*?\)/
    ]
    return markdownPatterns.some(pattern => pattern.test(text))
  }

  processMarkdown(text) {
    let html = text
    
    html = html.replace(/^######\s+(.+)$/gm, '<h6>$1</h6>')
    html = html.replace(/^#####\s+(.+)$/gm, '<h5>$1</h5>')
    html = html.replace(/^####\s+(.+)$/gm, '<h4>$1</h4>')
    html = html.replace(/^###\s+(.+)$/gm, '<h3>$1</h3>')
    html = html.replace(/^##\s+(.+)$/gm, '<h2>$1</h2>')
    html = html.replace(/^#\s+(.+)$/gm, '<h1>$1</h1>')
    
    html = html.replace(/\*\*\*(.*?)\*\*\*/g, '<strong><em>$1</em></strong>')
    html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    html = html.replace(/\*(.*?)\*/g, '<em>$1</em>')
    
    html = html.replace(/`(.*?)`/g, '<code>$1</code>')
    html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>')
    html = html.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1" />')
    
    html = html.replace(/\n\n/g, '</p><p>')
    html = html.replace(/\n/g, '<br>')
    
    if (!html.startsWith('<') || !html.includes('<p>')) {
      html = '<p>' + html + '</p>'
    }
    
    html = html.replace(/<p><\/p>/g, '')
    html = html.replace(/<p>\s*<\/p>/g, '')
    
    html = html.replace(/<p>&gt;\s*(.*?)<\/p>/g, '<blockquote><p>$1</p></blockquote>')
    html = html.replace(/^&gt;\s*(.*?)$/gm, '<blockquote><p>$1</p></blockquote>')
    
    const lines = html.split('<br>')
    let processedLines = []
    let inList = false
    let listType = null
    
    lines.forEach((line) => {
      const trimmedLine = line.trim()
      const unorderedMatch = trimmedLine.match(/^[\*\-]\s+(.+)$/)
      const orderedMatch = trimmedLine.match(/^\d+\.\s+(.+)$/)
      
      if (unorderedMatch) {
        if (!inList || listType !== 'ul') {
          if (inList) processedLines.push(`</${listType}>`)
          processedLines.push('<ul>')
          listType = 'ul'
          inList = true
        }
        processedLines.push(`<li>${unorderedMatch[1]}</li>`)
      } else if (orderedMatch) {
        if (!inList || listType !== 'ol') {
          if (inList) processedLines.push(`</${listType}>`)
          processedLines.push('<ol>')
          listType = 'ol'
          inList = true
        }
        processedLines.push(`<li>${orderedMatch[1]}</li>`)
      } else {
        if (inList) {
          processedLines.push(`</${listType}>`)
          inList = false
          listType = null
        }
        if (trimmedLine) processedLines.push(line)
      }
    })
    
    if (inList) processedLines.push(`</${listType}>`)
    
    return processedLines.join('<br>')
  }

  paginateHTML(htmlContent) {
    const tempDiv = document.createElement('div')
    tempDiv.innerHTML = htmlContent
    
    const textContent = tempDiv.textContent.trim()
    const paragraphs = htmlContent.split(/<\/p>|<br\s*\/?>/i)
    const pages = []

    if (paragraphs.length > 1) {
      let currentPage = ''
      let wordCount = 0
      
      paragraphs.forEach((paragraph, index) => {
        const pText = paragraph.replace(/<[^>]+>/g, '').trim()
        const pWords = pText.split(/\s+/).length
        
        if (wordCount + pWords > this.wordsPerPage && currentPage) {
          pages.push(currentPage)
          currentPage = paragraph + (index < paragraphs.length - 1 ? '</p>' : '')
          wordCount = pWords
        } else {
          currentPage += paragraph + (index < paragraphs.length - 1 ? '</p>' : '')
          wordCount += pWords
        }
      })
      
      if (currentPage) pages.push(currentPage)
    } else {
      const words = textContent.split(/\s+/)
      for (let i = 0; i < words.length; i += this.wordsPerPage) {
        const pageWords = words.slice(i, i + this.wordsPerPage)
        pages.push(pageWords.join(' '))
      }
    }
    
    return pages
  }

  paginateText(textContent) {
    const words = textContent.split(/\s+/).filter(word => word.length > 0)
    const pages = []
    for (let i = 0; i < words.length; i += this.wordsPerPage) {
      const pageWords = words.slice(i, i + this.wordsPerPage)
      pages.push(`<p>${pageWords.join(' ')}</p>`)
    }
    return pages
  }
}
