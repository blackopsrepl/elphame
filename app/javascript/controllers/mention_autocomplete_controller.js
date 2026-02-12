import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]
  static values = { 
    users: Array 
  }

  connect() {
    this.dropdownVisible = false
    this.selectedIndex = -1
    this.mentionStart = -1
    this.currentQuery = ""
    
    // Create dropdown if it doesn't exist
    if (!this.hasDropdownTarget) {
      this.createDropdown()
    }
  }

  createDropdown() {
    const dropdown = document.createElement('div')
    dropdown.dataset.mentionAutocompleteTarget = 'dropdown'
    dropdown.className = 'mention-dropdown hidden absolute z-50 bg-gray-900 border border-purple-800/50 rounded shadow-lg max-h-48 overflow-y-auto'
    dropdown.style.minWidth = '200px'
    this.element.style.position = 'relative'
    this.element.appendChild(dropdown)
  }

  async onInput(event) {
    const input = event.target
    const cursorPos = input.selectionStart
    const textBeforeCursor = input.value.substring(0, cursorPos)
    
    // Find last @ symbol before cursor
    const lastAtIndex = textBeforeCursor.lastIndexOf('@')
    
    if (lastAtIndex === -1) {
      this.hideDropdown()
      return
    }
    
    // Check if there's a space between @ and cursor (means mention is complete)
    const textAfterAt = textBeforeCursor.substring(lastAtIndex + 1)
    if (textAfterAt.includes(' ')) {
      this.hideDropdown()
      return
    }
    
    // Extract query after @
    this.mentionStart = lastAtIndex
    this.currentQuery = textAfterAt.toLowerCase()
    
    // Fetch users if we don't have them yet
    if (!this.usersValue || this.usersValue.length === 0) {
      await this.fetchUsers()
    }
    
    // Filter and show matches
    const matches = this.filterUsers(this.currentQuery)
    
    if (matches.length > 0) {
      this.showDropdown(matches, input)
    } else {
      this.hideDropdown()
    }
  }

  async fetchUsers() {
    try {
      const response = await fetch('/api/users')
      const data = await response.json()
      this.usersValue = data.users || []
    } catch (error) {
      console.error('Failed to fetch users:', error)
      this.usersValue = []
    }
  }

  filterUsers(query) {
    if (!this.usersValue) return []
    
    // Fuzzy matching: substring, word start, or Levenshtein distance < 3
    return this.usersValue
      .map(user => ({
        user: user,
        score: this.fuzzyScore(user.username.toLowerCase(), query)
      }))
      .filter(item => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 8)
      .map(item => item.user)
  }
  
  fuzzyScore(username, query) {
    if (!query) return 0
    
    const lower = username.toLowerCase()
    const q = query.toLowerCase()
    
    // Exact match (highest priority)
    if (lower === q) return 100
    
    // Starts with query (high priority)
    if (lower.startsWith(q)) return 90
    
    // Contains query as substring (medium priority)
    if (lower.includes(q)) return 70
    
    // Word boundary match (e.g., "terry" matches "KingTerry")
    const words = username.split(/(?=[A-Z])/).map(w => w.toLowerCase())
    for (let word of words) {
      if (word.startsWith(q)) return 60
      if (word.includes(q)) return 50
    }
    
    // Levenshtein distance (typo tolerance)
    const distance = this.levenshteinDistance(lower, q)
    if (distance <= 2) return 40 - (distance * 10)
    
    // Partial character match (very loose)
    const matched = q.split('').filter(c => lower.includes(c)).length
    const ratio = matched / q.length
    if (ratio > 0.6) return Math.floor(ratio * 30)
    
    return 0
  }
  
  levenshteinDistance(a, b) {
    const matrix = []
    
    for (let i = 0; i <= b.length; i++) {
      matrix[i] = [i]
    }
    
    for (let j = 0; j <= a.length; j++) {
      matrix[0][j] = j
    }
    
    for (let i = 1; i <= b.length; i++) {
      for (let j = 1; j <= a.length; j++) {
        if (b.charAt(i - 1) === a.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1]
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1, // substitution
            matrix[i][j - 1] + 1,     // insertion
            matrix[i - 1][j] + 1      // deletion
          )
        }
      }
    }
    
    return matrix[b.length][a.length]
  }

  showDropdown(matches, input) {
    const dropdown = this.dropdownTarget
    
    // Calculate position
    const rect = input.getBoundingClientRect()
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    
    dropdown.style.top = `${input.offsetHeight}px`
    dropdown.style.left = '0px'
    
    // Build dropdown content
    dropdown.innerHTML = matches.map((user, index) => `
      <div class="mention-item px-4 py-2 cursor-pointer hover:bg-purple-900/50 transition ${index === this.selectedIndex ? 'bg-purple-900/50' : ''}"
           data-index="${index}"
           data-username="${user.username}">
        <div class="flex items-center space-x-2">
          ${user.avatar_url ? 
            `<img src="${user.avatar_url}" class="w-6 h-6 rounded-full object-cover" />` :
            `<div class="w-6 h-6 rounded-full bg-purple-900 flex items-center justify-center text-purple-300 text-xs font-semibold">${user.username[0].toUpperCase()}</div>`
          }
          <span class="text-purple-300 text-sm font-medium">@${user.username}</span>
        </div>
      </div>
    `).join('')
    
    // Add click handlers
    dropdown.querySelectorAll('.mention-item').forEach(item => {
      item.addEventListener('click', (e) => {
        e.preventDefault()
        e.stopPropagation()
        const username = item.dataset.username
        this.insertMention(username, input)
      })
    })
    
    dropdown.classList.remove('hidden')
    this.dropdownVisible = true
    this.selectedIndex = -1
  }

  hideDropdown() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add('hidden')
      this.dropdownVisible = false
      this.selectedIndex = -1
    }
  }

  onKeydown(event) {
    if (!this.dropdownVisible) return
    
    const dropdown = this.dropdownTarget
    const items = dropdown.querySelectorAll('.mention-item')
    
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
      this.updateSelection(items)
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.selectedIndex = Math.max(this.selectedIndex - 1, -1)
      this.updateSelection(items)
    } else if (event.key === 'Enter' && this.selectedIndex >= 0) {
      event.preventDefault()
      const username = items[this.selectedIndex].dataset.username
      this.insertMention(username, event.target)
    } else if (event.key === 'Escape') {
      event.preventDefault()
      this.hideDropdown()
    }
  }

  updateSelection(items) {
    items.forEach((item, index) => {
      if (index === this.selectedIndex) {
        item.classList.add('bg-purple-900/50')
        item.scrollIntoView({ block: 'nearest' })
      } else {
        item.classList.remove('bg-purple-900/50')
      }
    })
  }

  insertMention(username, input) {
    const value = input.value
    const beforeMention = value.substring(0, this.mentionStart)
    const afterCursor = value.substring(input.selectionStart)
    
    const newValue = `${beforeMention}@${username} ${afterCursor}`
    input.value = newValue
    
    // Move cursor after mention
    const newCursorPos = this.mentionStart + username.length + 2
    input.setSelectionRange(newCursorPos, newCursorPos)
    
    this.hideDropdown()
    input.focus()
  }

  onBlur(event) {
    // Delay hiding to allow click events on dropdown
    setTimeout(() => {
      this.hideDropdown()
    }, 200)
  }
}
