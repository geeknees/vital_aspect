import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['container', 'addButton']

  connect() {
    this.keyResultIndex = this.containerTarget.querySelectorAll(
      '.key-result-fields, .key-result-item'
    ).length
    this.setupEventListeners()
  }

  setupEventListeners() {
    // Add new key result
    this.addButtonTarget.addEventListener('click', (e) => {
      e.preventDefault()
      this.addKeyResult()
    })

    // Remove key result (using event delegation)
    this.containerTarget.addEventListener('click', (e) => {
      if (e.target.closest('.remove-key-result')) {
        e.preventDefault()
        this.removeKeyResult(
          e.target.closest('.key-result-fields, .key-result-item')
        )
      }
    })
  }

  addKeyResult() {
    // Check if we're on the edit page (has template) or new page
    const template = document.getElementById('key-result-template')

    if (template) {
      // Edit page - use template
      this.addKeyResultFromTemplate()
    } else {
      // New page - use inline template
      this.addKeyResultInline()
    }
  }

  addKeyResultFromTemplate() {
    const template = document.getElementById('key-result-template')
    const newKeyResult = template.content.cloneNode(true)

    // Replace NEW_RECORD with actual index
    const tempDiv = document.createElement('div')
    tempDiv.appendChild(newKeyResult)
    tempDiv.innerHTML = tempDiv.innerHTML.replace(
      /NEW_RECORD/g,
      this.keyResultIndex
    )

    this.containerTarget.appendChild(tempDiv.firstElementChild)
    this.keyResultIndex++
  }

  addKeyResultInline() {
    const template = `
      <div class="key-result-fields border border-gray-200 rounded-lg p-6">
        <div class="flex justify-between items-start mb-4">
          <h4 class="text-lg font-medium text-gray-800">Key Result</h4>
          <button type="button" class="remove-key-result text-red-600 hover:text-red-800">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>

        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">タイトル</label>
            <input type="text" name="okr[key_results_attributes][${this.keyResultIndex}][title]"
                   placeholder="例: NPS（ネット推奨者スコア）を改善する"
                   class="block w-full text-base px-3 py-2 border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">説明</label>
            <textarea name="okr[key_results_attributes][${this.keyResultIndex}][description]" rows="2"
                      placeholder="Key Resultの詳細説明"
                      class="block w-full text-base px-3 py-2 border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"></textarea>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">目標値</label>
              <input type="number" step="0.01" name="okr[key_results_attributes][${this.keyResultIndex}][target_value]"
                     placeholder="100"
                     class="block w-full text-base px-3 py-2 border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">現在値</label>
              <input type="number" step="0.01" name="okr[key_results_attributes][${this.keyResultIndex}][current_value]"
                     placeholder="0" value="0"
                     class="block w-full text-base px-3 py-2 border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">単位</label>
              <input type="text" name="okr[key_results_attributes][${this.keyResultIndex}][unit]"
                     placeholder="ポイント"
                     class="block w-full text-base px-3 py-2 border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">ステータス</label>
              <select name="okr[key_results_attributes][${this.keyResultIndex}][status]"
                      class="block w-full text-base px-3 py-2 border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                <option value="not_started">未開始</option>
                <option value="in_progress">進行中</option>
                <option value="completed">完了</option>
                <option value="at_risk">リスク</option>
              </select>
            </div>
          </div>
        </div>

        <input type="hidden" name="okr[key_results_attributes][${this.keyResultIndex}][_destroy]" class="destroy-field" value="false">
      </div>
    `

    this.containerTarget.insertAdjacentHTML('beforeend', template)
    this.keyResultIndex++
  }

  removeKeyResult(keyResultField) {
    const destroyField = keyResultField.querySelector('.destroy-field')

    if (destroyField && destroyField.name.includes('[id]')) {
      // Existing record - mark for destruction
      destroyField.value = 'true'
      keyResultField.style.display = 'none'
    } else {
      // New record - remove from DOM
      keyResultField.remove()
    }
  }
}
