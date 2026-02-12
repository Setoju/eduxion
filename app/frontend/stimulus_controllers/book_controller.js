import { Controller } from "@hotwired/stimulus"
import BookService from "../features/book/book_service"

export default class extends Controller {
  static targets = ["page", "currentPage", "totalPages", "prevButton", "nextButton", "content"]
  static values = { 
    currentPage: Number,
    wordsPerPage: Number
  }

  connect() {
    this.currentPageValue = this.currentPageValue || 1
    this.wordsPerPageValue = this.wordsPerPageValue || 200
    this.service = new BookService(this.wordsPerPageValue)
    
    this.setupPages()
    this.createPageElements()
    this.populatePageSelector()
    this.updateDisplay()
  }

  setupPages() {
    this.pages = this.service.getPages(this.contentTarget)
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
      selector.max = this.totalPagesValue
      selector.min = 1
    }
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
    let pageNumber = parseInt(event.target.value)
    
    if (isNaN(pageNumber)) {
      if (event.type === 'change') {
        event.target.value = this.currentPageValue
      }
      return
    }

    // Clamp the value if it's out of bounds
    if (pageNumber > this.totalPagesValue) {
      pageNumber = this.totalPagesValue
      event.target.value = pageNumber
    } else if (pageNumber < 1) {
      pageNumber = 1
      event.target.value = pageNumber
    }

    if (pageNumber !== this.currentPageValue) {
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