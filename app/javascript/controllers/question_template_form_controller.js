import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'questionTypeSelect',
    'optionsSection',
    'optionsContainer'
  ]

  connect() {
    this.toggleOptions()
  }

  toggleOptions() {
    const type = this.questionTypeSelectTarget.value
    if (type === 'multiple_choice' || type === 'rating') {
      this.optionsSectionTarget.classList.remove('hidden')
      if (type === 'rating') {
        this.setRatingOptions()
      }
    } else {
      this.optionsSectionTarget.classList.add('hidden')
    }
  }

  setRatingOptions() {
    this.optionsContainerTarget.innerHTML = ''
    for (let i = 1; i <= 5; i++) {
      const row = document.createElement('div')
      row.className = 'flex items-center mb-2 option-row'
      row.innerHTML = `
        <input type="text" name="question_template[options][]" value="${i}" readonly class="flex-1 border-gray-300 rounded-md shadow-sm bg-gray-50">
        <span class="ml-2 text-sm text-gray-600">${this.getRatingLabel(i)}</span>
      `
      this.optionsContainerTarget.appendChild(row)
    }
  }

  getRatingLabel(rating) {
    return this.element.dataset[`rating${rating}Label`]
  }

  addOption() {
    const row = document.createElement('div')
    row.className = 'flex items-center mb-2 option-row'
    row.innerHTML = `
      <input type="text" name="question_template[options][]" placeholder="${this.element.dataset.optionPlaceholder}" class="flex-1 border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
      <button type="button" data-action="question-template-form#removeOption" class="ml-2 text-red-600 hover:text-red-900">
        <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
        </svg>
      </button>
    `
    this.optionsContainerTarget.appendChild(row)
  }

  removeOption(event) {
    event.currentTarget.parentElement.remove()
  }
}
