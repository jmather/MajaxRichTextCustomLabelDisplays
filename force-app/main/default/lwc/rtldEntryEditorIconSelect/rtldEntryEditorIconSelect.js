import { LightningElement, api, track } from 'lwc';
import { icons } from './icons';
import debug from 'c/debug';

export default class RtldEntryEditorIconSelect extends LightningElement {
    @api enableDebugging = false;
    @api value;
    @api placeHolder = 'Select an Icon';
    @track selectedValue;
    @track _showModal = false;
    @track _value = null;
    @track categoryList = [];
    @track iconList = icons;
    @track filterText = '';

    filterInterval = 3000;
    filterTimeout = null;

    constructor() {
        super();
        this.categoryList = this._buildIconCategories();
    }

    get showModal() { return this._showModal; }
    get categories() { return this.categoryList; }
    get isFiltered() { return this.filterText !== ''; }
    get filteredIcons() {
        debug(this.enableDebugging, 'RtldEntryEditorIconSelect.filteredIcons', this.filterText);

        return this.iconList.filter(icon => {
            const matches = icon.name.includes(this.filterText);
            debug(this.enableDebugging, 'RtldEntryEditorIconSelect.filteredIcons', { name: icon.name, matches });
            return matches;
        });
    }

    connectedCallback() {
        this._value = this.value;
    }

    handleCloseModalClick() {
        this._showModal = false;
    }

    handleOpenModalClick() {
        this._showModal = true;
    }

    handleIconClick(icon) {
        this._showModal = false;
        debug(this.enableDebugging, 'RtldEntryEditorIconSelect.handleIconClick', icon);
        this._value = icon.full_id;
        this._dispatchChanged();
    }

    handleClearIconClick(event) {
        event.preventDefault();
        debug.event(this.enableDebugging, 'RtldEntryEditorIconSelect.handleClearIconClick', event);
        this._value = null;
        this._dispatchChanged();
    }

    handleFilterChange(event) {
        debug.event(this.enableDebugging, 'RtldEntryEditorIconSelect.handleFilterChange', event);
        const filter = event.detail.value;

        if (this.filterTimeout !== null) {
            clearTimeout(this.filterTimeout);
        }

        const controller = this;
        this.filterTimeout = setTimeout(() => controller.filterText = filter, this.filterInterval);
    }

    _dispatchChanged() {
        debug(this.enableDebugging, 'RtldEntryEditorIconSelect._dispatchChanged', this._value);
        this.dispatchEvent(new CustomEvent('change', { detail: { value: this._value }}));
    }

    _buildIconCategories() {
        const controller = this;
        const categories = [];
        const iconsByCategory = {};

        for (let i = 0; i < icons.length; i++) {
            const icon = icons[i];
            icon.selected = () => {
                controller.handleIconClick(icon);
                return false;
            };
            icon.display = true;

            if (iconsByCategory.hasOwnProperty(icon.category) === false) {
                iconsByCategory[icon.category] = {
                    name: icon.category.substring(0, 1).toUpperCase() + icon.category.substring(1),
                    icons: [icon],
                };
                categories.push(iconsByCategory[icon.category]);
            } else {
                iconsByCategory[icon.category].icons.push(icon);
            }
        }

        return categories;
    }
}