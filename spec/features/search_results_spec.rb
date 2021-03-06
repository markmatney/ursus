# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "Search results page" do
  before do
    solr = Blacklight.default_index.connection
    solr.add(work_1_attributes)
    solr.add(work_2_attributes)
    solr.add(work_3_attributes)
    solr.commit
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://example.com')
  end

  let(:work_1_attributes) do
    {
      id: 'id123',
      has_model_ssim: ['Work'],
      title_tesim: ['Title One'],
      identifier_tesim: ['ark 123'],
      description_tesim: ['Description 1', 'Description 2'],
      date_created_tesim: ["Date 1"],
      sort_year_isi: 1923,
      human_readable_resource_type_tesim: ['still image'],
      subject_tesim: ['Testing', 'RSpec'],
      photographer_tesim: ['Person 1', 'Person 2'],
      location_tesim: ['search_results_spec'], # to control what displays,
      thumbnail_path_ss: ["/assets/work-ff055336041c3f7d310ad69109eda4a887b16ec501f35afc0a547c4adb97ee72.png"]
    }
  end

  let(:work_2_attributes) do
    {
      id: 'id456',
      has_model_ssim: ['Work'],
      title_tesim: ['Title Two'],
      identifier_tesim: ['ark 456'],
      description_tesim: ['Description 3', 'Description 4'],
      date_created_tesim: ["Date 1"],
      sort_year_isi: 1945,
      human_readable_resource_type_tesim: ['still image'],
      subject_tesim: ['Testing', 'Minitest'],
      photographer_tesim: ['Person 1'],
      location_tesim: ['search_results_spec'], # to control what displays
      collection_tesim: ['Slide Film', 'Analog', 'Photographs']
    }
  end

  let(:work_3_attributes) do
    {
      id: 'id456',
      has_model_ssim: ['Work'],
      title_tesim: ['Title Three'],
      identifier_tesim: ['ark 456'],
      description_tesim: ['Description 3', 'Description 4', 'another desc'],
      date_created_tesim: ["Date 1"],
      sort_year_isi: 1929,
      human_readable_resource_type_tesim: ['still image'],
      photographer_tesim: ['Person 1'],
      location_tesim: ['search_results_spec'], # to control what displays
      collection_tesim: ['Photographs', 'Digital']
    }
  end

  scenario 'displays: title, description, date_created, resource_type, and photographer' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec'
    expect(page).to have_content 'Title One'
    expect(page).to have_content 'Description: Description 1'
    expect(page).not_to have_content 'Description 2'
    expect(page).to have_content 'Resource Type: still image'
    expect(page).to have_content 'Date Created: 1923'
    expect(page).to have_content 'Photographer: Person 1'
  end

  scenario 'displays facetable fields as links' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec'
    expect(page).to have_link 'Title One'
    expect(page).to have_link 'still image'
    expect(page).not_to have_link '1923'
    expect(page).to have_link 'Person 1'
  end

  scenario 'displays the old site link with page results' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec'
    expect(page).to have_link 'original digital collections site'
  end

  scenario 'displays the old site link on page with no results' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=zebra'
    expect(page).to have_link 'original digital collections site'
  end

  scenario 'displays line breaks between the values of certain fields' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec'
    expect(page.all('br').length).to eq 1
  end

  scenario 'uses AND not OR for search results by default' do
    visit '/catalog?search_field=all_fields&q=Description+desc'
    expect(page).to have_content 'Title Three'
    expect(page).not_to have_content 'Title One'
  end

  scenario 'displays Gallery View button' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec'
    expect(page).to have_link 'Gallery'
  end

  scenario 'displays List View button' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec'
    expect(page).to have_link 'List'
  end

  scenario 'displays Gallery View results' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec&view=gallery'
    click_on 'Gallery'
    expect(page).to have_selector('.view-type-gallery.active')
    expect(page).to have_content 'Title One'
  end

  scenario 'displays List View results' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec&view=list'
    click_on 'List'
    expect(page).to have_selector('.view-type-list.active')
    expect(page).to have_content 'Title One'
    expect(page).to have_content 'Description: Description 1'
    expect(page).to have_content 'Resource Type: still image'
    expect(page).to have_content 'Date Created: 1923'
  end

  scenario 'visiting the home page and getting the correct search field options' do
    visit '/' do
      expect(page.html).to match(/<option value="all_fields">All Fields<\/option>/)
      expect(page.html).to match(/<option value="title">Title<\/option>/)
      expect(page.html).to match(/<option value="subject">Subject<\/option>/)
      expect(page.html).to match(/<option value="description">Collection<\/option>/)
    end
  end

  scenario 'using the drop down search and getting the correct results' do
    visit '/catalog?search_field=title&q=Title One' do
      expect(page).to have_content('1 Catalog Results')
    end

    visit '/catalog?search_field=subject&q=Minitest' do
      expect(page).to have_content('1 Catalog Results')
    end

    visit '/catalog?search_field=collection&q=photographs' do
      expect(page).to have_content('2 Catalog Results')
    end
  end
end
