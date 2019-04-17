# frozen_string_literal: true

require 'rails_helper'

RSpec.feature "ARK-based ids", js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add(work_1_attributes)
    solr.add(work_2_attributes)
    solr.add(collection_1_attributes)
    solr.commit
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://example.com')
    allow_any_instance_of(IiifService).to receive(:src).and_return('/uv/uv.html#?manifest=/manifest.json')
  end

  let(:id) { '7654321-fedcba' }

  let(:work_1_attributes) do
    {
      id: id,
      ark_ssi: 'ark:/abcdef/1234567'
      ursus_id_ssi: 'abcdef-1234567'
      has_model_ssim: ['Work'],
      title_tesim: ['The molecular rocky brother maybe'],
    }
  end
  
  let(:work_2_attributes) do
    {
      id: 'fffffff-99999',
      ark_ssi: 'ark:/99999/fffffff',
      ursus_id_ssi: '99999-fffffff'
      has_model_ssim: ['Work'],
      title_tesim: ['Title One'],
    }
  end

  let(:collection_1_attributes) do
    {
      id: 'fffffff-99999',
      ark_ssi: 'ark:/99999/fffffff',
      ursus_id_ssi: '99999-fffffff'
      has_model_ssim: ['Collection'],
      title_tesim: ['My sample collection'],
      identifier_tesim: ['ark 456'],
      description_tesim: ['Description 3', 'Description 4'],
      date_created_tesim: ["Date 1"],
      resource_type_tesim: ['still image'],
      photographer_tesim: ['Person 1'],
      location_tesim: ['search_results_spec'] # to control what displays
    }
  end

  scenario 'can be used to directly access works' do
    visit '/catalog/abcdef-1234567'
    expect(page).to have_text 'The molecular rocky brother maybe'
  end

  scenario 'displays the old site link with page results' do
    visit '/catalog?f%5Blocation_tesim%5D%5B%5D=search_results_spec'
    expect(page).to have_link 'original digital collections site'
  end

end
