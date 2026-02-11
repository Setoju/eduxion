import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["page", "currentPage", "totalPages", "prevButton", "nextButton", "content"]
  static values = { 
    currentPage: Number,
    wordsPerPage: Number
  }

  connect() {
    this.currentPageValue = 1
    this.wordsPerPageValue = 200 // Adjust words per page as needed
    this.setupPages()
    this.createPageElements()
    this.populatePageSelector()
    this.updateDisplay()
  }

  setupPages() {
    let content = this.contentTarget.textContent.trim()
    
    // Process markdown if the content appears to use markdown syntax
    if (this.containsMarkdown(content)) {
      content = this.processMarkdown(content)
    } else if (this.contentTarget.innerHTML.includes('<')) {
      // Use HTML content if it's already formatted
      content = this.contentTarget.innerHTML
    }
    
    const words = content.replace(/<[^>]*>/g, ' ').split(/\s+/).filter(word => word.length > 0)
    this.pages = []
    
    // Split content into pages based on word count
    if (content.includes('<')) {
      this.setupHTMLPages(content)
    } else {
      // Simple text splitting
      for (let i = 0; i < words.length; i += this.wordsPerPageValue) {
        const pageWords = words.slice(i, i + this.wordsPerPageValue)
        this.pages.push(pageWords.join(' '))
      }
    }
    
    this.totalPagesValue = Math.max(1, this.pages.length)
  }

  createPageElements() {
    const container = this.pageTargets[0].parentElement
    // Clear existing pages
    this.pageTargets.forEach(page => page.remove())
    
    // Create pages for all content
    this.pages.forEach((pageContent, index) => {
      const pageElement = document.createElement('div')
      pageElement.className = 'book-page'
      pageElement.setAttribute('data-book-target', 'page')
      pageElement.style.display = index === 0 ? 'block' : 'none'
      
      const contentDiv = document.createElement('div')
      contentDiv.className = 'page-content'
      contentDiv.innerHTML = pageContent
      
      pageElement.appendChild(contentDiv)
      container.appendChild(pageElement)
    })
  }

  populatePageSelector() {
    const selector = this.element.querySelector('#page-select')
    if (selector) {
      selector.innerHTML = ''
      for (let i = 1; i <= this.totalPagesValue; i++) {
        const option = document.createElement('option')
        option.value = i
        option.textContent = i
        if (i === this.currentPageValue) {
          option.selected = true
        }
        selector.appendChild(option)
      }
    }
  }

  containsMarkdown(text) {
    // Check for common markdown patterns
    const markdownPatterns = [
      /^#{1,6}\s+/m,           // Headers
      /\*\*.*?\*\*/,           // Bold
      /\*.*?\*/,               // Italic
      /`.*?`/,                 // Inline code
      /^\*\s+/m,               // Unordered list
      /^\d+\.\s+/m,            // Ordered list
      /^\>\s+/m,               // Blockquote
      /!\[.*?\]\(.*?\)/,       // Images
      /\[.*?\]\(.*?\)/         // Links
    ]
    
    return markdownPatterns.some(pattern => pattern.test(text))
  }

  processMarkdown(text) {
    let html = text
    
    // Headers (must be at start of line)
    html = html.replace(/^######\s+(.+)$/gm, '<h6>$1</h6>')
    html = html.replace(/^#####\s+(.+)$/gm, '<h5>$1</h5>')
    html = html.replace(/^####\s+(.+)$/gm, '<h4>$1</h4>')
    html = html.replace(/^###\s+(.+)$/gm, '<h3>$1</h3>')
    html = html.replace(/^##\s+(.+)$/gm, '<h2>$1</h2>')
    html = html.replace(/^#\s+(.+)$/gm, '<h1>$1</h1>')
    
    // Bold and italic (order matters!)
    html = html.replace(/\*\*\*(.*?)\*\*\*/g, '<strong><em>$1</em></strong>')
    html = html.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    html = html.replace(/\*(.*?)\*/g, '<em>$1</em>')
    
    // Inline code
    html = html.replace(/`(.*?)`/g, '<code>$1</code>')
    
    // Links
    html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>')
    
    // Images
    html = html.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1" />')
    
    // Line breaks and paragraphs
    html = html.replace(/\n\n/g, '</p><p>')
    html = html.replace(/\n/g, '<br>')
    
    // Wrap in paragraph tags if not already wrapped
    if (!html.startsWith('<') || !html.includes('<p>')) {
      html = '<p>' + html + '</p>'
    }
    
    // Clean up empty paragraphs
    html = html.replace(/<p><\/p>/g, '')
    html = html.replace(/<p>\s*<\/p>/g, '')
    
    // Blockquotes (must be processed after paragraphs)
    html = html.replace(/<p>&gt;\s*(.*?)<\/p>/g, '<blockquote><p>$1</p></blockquote>')
    html = html.replace(/^&gt;\s*(.*?)$/gm, '<blockquote><p>$1</p></blockquote>')
    
    // Lists - process line by line for better structure
    const lines = html.split('<br>')
    let processedLines = []
    let inList = false
    let listType = null
    
    lines.forEach((line, index) => {
      const trimmedLine = line.trim()
      
      // Check if this line is a list item
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
    
    // Close any remaining list
    if (inList) {
      processedLines.push(`</${listType}>`)
    }
    
    html = processedLines.join('<br>')
    
    return html
  }

  setupHTMLPages(htmlContent) {
    const tempDiv = document.createElement('div')
    tempDiv.innerHTML = htmlContent
    
    const textContent = tempDiv.textContent.trim()
    const words = textContent.split(/\s+/)
    this.pages = []
    
    // Simple HTML pagination - split by paragraphs if possible
    const paragraphs = htmlContent.split(/<\/p>|<br\s*\/?>/i)
    if (paragraphs.length > 1) {
      let currentPage = ''
      let wordCount = 0
      
      paragraphs.forEach((paragraph, index) => {
        const pText = paragraph.replace(/<[^>]+>/g, '').trim()
        const pWords = pText.split(/\s+/).length
        
        if (wordCount + pWords > this.wordsPerPageValue && currentPage) {
          this.pages.push(currentPage)
          currentPage = paragraph + (index < paragraphs.length - 1 ? '</p>' : '')
          wordCount = pWords
        } else {
          currentPage += paragraph + (index < paragraphs.length - 1 ? '</p>' : '')
          wordCount += pWords
        }
      })
      
      if (currentPage) {
        this.pages.push(currentPage)
      }
    } else {
      // Fallback to word-based splitting
      const words = textContent.split(/\s+/)
      for (let i = 0; i < words.length; i += this.wordsPerPageValue) {
        const pageWords = words.slice(i, i + this.wordsPerPageValue)
        this.pages.push(pageWords.join(' '))
      }
    }
    
    this.totalPagesValue = this.pages.length
  }

  updateDisplay() {
    // Update page content
    this.pageTargets.forEach((page, index) => {
      if (index === this.currentPageValue - 1) {
        page.style.display = 'block'
        // Content is already set in createPageElements
      } else {
        page.style.display = 'none'
      }
    })
    
    // Update page numbers
    if (this.hasCurrentPageTarget) {
      this.currentPageTarget.textContent = this.currentPageValue
    }
    if (this.hasTotalPagesTarget) {
      this.totalPagesTarget.textContent = this.totalPagesValue
    }
    
    // Update page selector
    const selector = this.element.querySelector('#page-select')
    if (selector) {
      selector.value = this.currentPageValue
    }
    
    // Update button states
    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.disabled = this.currentPageValue === 1
    }
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = this.currentPageValue === this.totalPagesValue
    }
  }

  previousPage() {
    if (this.currentPageValue > 1) {
      this.currentPageValue--
      this.updateDisplay()
      this.addPageTurnEffect('left')
    }
  }

  nextPage() {
    if (this.currentPageValue < this.totalPagesValue) {
      this.currentPageValue++
      this.updateDisplay()
      this.addPageTurnEffect('right')
    }
  }

  goToPage(event) {
    const pageNumber = parseInt(event.target.value)
    if (pageNumber >= 1 && pageNumber <= this.totalPagesValue) {
      this.currentPageValue = pageNumber
      this.updateDisplay()
    }
  }

  addPageTurnEffect(direction) {
    const activePageTarget = this.pageTargets[this.currentPageValue - 1]
    if (activePageTarget) {
      activePageTarget.classList.add(`page-turn-${direction}`)
      setTimeout(() => {
        activePageTarget.classList.remove(`page-turn-${direction}`)
      }, 300)
    }
  }

  // Keyboard navigation
  keydown(event) {
    if (event.key === 'ArrowRight' || event.key === ' ') {
      event.preventDefault()
      this.nextPage()
    } else if (event.key === 'ArrowLeft') {
      event.preventDefault()
      this.previousPage()
    }
  }
}